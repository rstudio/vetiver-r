#' Aggregate, store, and plot model metrics over time for monitoring
#'
#' These three functions can be used for model monitoring (such as in a
#' monitoring dashboard):
#' - `vetiver_compute_metrics()` computes metrics (such as accuracy for a
#' classification model or RMSE for a regression model) at a chosen time
#' aggregation `.period`
#' - `vetiver_pin_metrics()` updates an existing pin storing model metrics
#' over time
#' - `vetiver_plot_metrics()` creates a plot of metrics over time
#'
#' @inheritParams yardstick::metrics
#' @inheritParams pins::pin_read
#' @inheritParams slider::slide_period
#' @param date_var The column in `data` containing dates or date-times for
#' monitoring, to be aggregated with `.period`
#' @param metric_set A [yardstick::metric_set()] function for computing metrics.
#' Defaults to [yardstick::metrics()].
#' @param df_metrics A tidy dataframe of metrics over time, such as created by
#' `vetiver_compute_metrics()`.
#' @param metrics_pin_name Pin name for where the *metrics* are stored (as
#' opposed to where the model object is stored with [vetiver_pin_write()]).
#' @param overwrite If `FALSE` (the default), error when the new metrics contain
#' overlapping dates with the existing pin.If `TRUE`, overwrite any metrics for
#' dates that exist both in the existing pin and new metrics with the _new_
#' values.
#' @param .index The variable in `df_metrics` containing the aggregated dates
#' or date-times (from `time_var` in `data`). Defaults to `.index`.
#' @param .estimate The variable in `df_metrics` containing the metric estimate.
#' Defaults to `.estimate`.
#' @param .metric The variable in `df_metrics` containing the metric type.
#' Defaults to `.metric`.
#' @param .n The variable in `df_metrics` containing the number of observations
#' used for estimating the metric.
#'
#' @return Both `vetiver_compute_metrics()` and `vetiver_pin_metrics()` return
#' a dataframe of metrics. The `vetiver_plot_metrics()` function returns a
#' `ggplot2` object.
#'
#' @details Sometimes when you monitor a model at a given time aggregation, you
#' may end up with dates in your new metrics (like `new_metrics` in the example)
#' that are the same as dates in your existing aggregated metrics (like
#' `original_metrics` in the example). This can happen if you need to re-run a
#' monitoring report because something failed. With `overwrite = FALSE` (the
#' default), `vetiver_pin_metrics()` will error when there are overlapping
#' dates. With `overwrite = TRUE`, `vetiver_pin_metrics()` will replace such
#' metrics with the new values. You probably want `FALSE` for interactive use
#' and `TRUE` for dashboards or reports that run on a schedule.
#'
#' For arguments used more than once in your monitoring dashboard,
#' such as `date_var`, consider using
#' [R Markdown parameters](https://bookdown.org/yihui/rmarkdown/parameterized-reports.html)
#' to reduce repetition and/or errors.
#'
#' @examplesIf rlang::is_installed(c("dplyr", "parsnip", "modeldata", "ggplot2"))
#' library(dplyr)
#' library(parsnip)
#' data(Chicago, package = "modeldata")
#' Chicago <- Chicago %>% select(ridership, date, all_of(stations))
#' training_data <- Chicago %>% filter(date < "2009-01-01")
#' testing_data <- Chicago %>% filter(date >= "2009-01-01", date < "2011-01-01")
#' monitoring <- Chicago %>% filter(date >= "2011-01-01", date < "2012-12-31")
#' lm_fit <- linear_reg() %>% fit(ridership ~ ., data = training_data)
#'
#' library(pins)
#' b <- board_temp()
#'
#' ## before starting monitoring, initiate the metrics and pin
#' ## (for example, with the testing data):
#' original_metrics <-
#'     augment(lm_fit, new_data = testing_data) %>%
#'     vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
#' pin_write(b, original_metrics, "lm_fit_metrics")
#'
#' ## to continue monitoring with new data, compute metrics and update pin:
#' new_metrics <-
#'     augment(lm_fit, new_data = monitoring) %>%
#'     vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
#' vetiver_pin_metrics(b, new_metrics, "lm_fit_metrics")
#'
#' library(ggplot2)
#' vetiver_plot_metrics(new_metrics) +
#'     scale_size(range = c(2, 4))
#'
#' @export
vetiver_compute_metrics <- function(data,
                                    date_var,
                                    period,
                                    truth, estimate, ...,
                                    metric_set = yardstick::metrics,
                                    every = 1L,
                                    origin = NULL,
                                    before = 0L,
                                    after = 0L,
                                    complete = FALSE) {

    rlang::check_installed("slider")
    truth_quo <- enquo(truth)
    estimate_quo <- enquo(estimate)

    # Figure out which column in `data` corresponds to `date_var`
    date_var <- enquo(date_var)
    date_var <- eval_select_one(date_var, data, "date_var")

    index <- data[[date_var]]

    slider::slide_period_dfr(
        .x = data,
        .i = index,
        .period = period,
        .f = compute_metrics,
        date_var = date_var,
        metric_set = metric_set,
        truth_quo = truth_quo,
        estimate_quo = estimate_quo,
        ...,
        .every = every,
        .origin = origin,
        .before = before,
        .after = after,
        .complete = complete
    )

}

#' @rdname vetiver_compute_metrics
#' @export
vetiver_pin_metrics <- function(board,
                                df_metrics,
                                metrics_pin_name,
                                .index = .index,
                                overwrite = FALSE) {
    .index <- enquo(.index)
    .index <- eval_select_one(.index, df_metrics, "date_var")
    new_dates <- unique(df_metrics[[.index]])

    old_metrics <- pins::pin_read(board, metrics_pin_name)
    overlapping_dates <- old_metrics[[.index]] %in% new_dates
    if (overwrite) {
        old_metrics <- vec_slice(old_metrics, !overlapping_dates)
    } else {
        if (any(overlapping_dates))
            abort(c(
                glue("The new metrics overlap with dates \\
                     already stored in {glue::single_quote(metrics_pin_name)}"),
                i = "Check the aggregated dates or use `overwrite = TRUE`"
            ))
    }
    new_metrics <- vctrs::vec_rbind(old_metrics, df_metrics)
    new_metrics <- vec_slice(
        new_metrics,
        vctrs::vec_order(new_metrics[[.index]])
    )

    pins::pin_write(board, new_metrics, basename(metrics_pin_name))
    new_metrics

}

compute_metrics <- function(data,
                            date_var,
                            metric_set,
                            truth_quo,
                            estimate_quo,
                            ...) {
    index <- data[[date_var]]
    index <- min(index)

    n <- nrow(data)

    metrics <- metric_set(
        data = data,
        truth = !!truth_quo,
        estimate = !!estimate_quo,
        ...
    )

    tibble::tibble(
        .index = index,
        .n = n,
        metrics
    )
}

eval_select_one <- function(col, data, arg, ..., call = caller_env()) {
    rlang::check_installed("tidyselect")
    check_dots_empty()

    # `col` is a quosure that has its own environment attached
    env <- empty_env()

    loc <- tidyselect::eval_select(
        expr = col,
        data = data,
        env = env,
        error_call = call
    )

    if (length(loc) != 1L) {
        message <- glue::glue("`{arg}` must specify exactly one column from `data`.")
        abort(message, call = call)
    }

    loc
}

#' @rdname vetiver_compute_metrics
#' @export
vetiver_plot_metrics <- function(df_metrics,
                                 .index = .index,
                                 .estimate = .estimate,
                                 .metric = .metric,
                                 .n = .n) {
    rlang::check_installed("ggplot2")
    .metric <- enquo(.metric)

    ggplot2::ggplot(data = df_metrics,
                    ggplot2::aes({{ .index }}, {{.estimate}})) +
        ggplot2::geom_line(ggplot2::aes(color = !!.metric), alpha = 0.7) +
        ggplot2::geom_point(ggplot2::aes(color = !!.metric,
                                         size = {{.n}}),
                            alpha = 0.9) +
        ggplot2::facet_wrap(ggplot2::vars(!!.metric),
                            scales = "free_y", ncol = 1) +
        ggplot2::guides(color = "none") +
        ggplot2::labs(x = NULL, y = NULL, size = NULL)
}
