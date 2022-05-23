#' Aggregate, store, and plot model metrics over time for monitoring
#'
#' These three functions can be used for model monitoring (such as in a
#' monitoring dashboard):
#' - `vetiver_compute_metrics()` computes metrics (such as accuracy for a
#' classification model or RMSE for a regression model) at a chosen time
#' aggregation `.period`
#' - `vetiver_pin_metrics()` updates (or creates) a pin storing model metrics
#' over time
#' - `vetiver_plot_metrics()` creates a plot of metrics over time
#'
#' @inheritParams yardstick::metrics
#' @inheritParams pins::pin_read
#' @inheritParams slider::slide_period
#' @param date_var The column in `data` containing dates or date-times for
#' monitoring, to be aggregated with `unit`
#' @param metric_set A [yardstick::metric_set()] function for computing metrics.
#' Defaults to [yardstick::metrics()].
#' @param df_metrics A tidy dataframe of metrics over time, such as created by
#' `vetiver_compute_metrics()`.
#' @param metrics_pin_name Pin name for where the *metrics* are stored (as
#' opposed to where the model object is stored with [vetiver_pin_write()]).
#' @param initiate Are you starting a new set of monitoring metrics to
#' pin/store? Defaults to `FALSE`.
#' @param .estimate The variable in `df_metrics` containing the metric estimate.
#' Defaults to `.estimate`.
#' @param .metric The variable in `df_metrics` containing the metric type.
#' Defaults to `.metric`.
#' @param n The variable in `df_metrics` containing the number of observations
#' used for estimating the metric.
#'
#' @return Both `vetiver_compute_metrics()` and `vetiver_pin_metrics()` return
#' a dataframe of metrics. The `vetiver_plot_metrics()` function returns a
#' `ggplot2` object.
#'
#' @details For arguments used more than once in your monitoring dashboard,
#' such as `date_var`, consider using
#' [R Markdown parameters](https://bookdown.org/yihui/rmarkdown/parameterized-reports.html)
#' to reduce repetition and/or errors.
#'
#' @examples
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
#'     vetiver_compute_metrics(date, "week", ridership, .pred, .every = 4L) %>%
#'     vetiver_pin_metrics(date, b, "lm_fit_metrics", initiate = TRUE)
#'
#' ## to continue monitoring with new data, compute metrics and update pin:
#' new_metrics <-
#'     augment(lm_fit, new_data = monitoring) %>%
#'     vetiver_compute_metrics(date, "week", ridership, .pred, .every = 4L) %>%
#'     vetiver_pin_metrics(date, b, "lm_fit_metrics")
#'
#' library(ggplot2)
#' vetiver_plot_metrics(new_metrics, date) +
#'     scale_size(range = c(2, 4))
#'
#' @export
vetiver_compute_metrics <- function(data,
                                    date_var,
                                    .period,
                                    truth, estimate, ...,
                                    metric_set = yardstick::metrics,
                                    .every = 1L,
                                    .origin = NULL,
                                    .before = 0L,
                                    .after = 0L,
                                    .complete = FALSE) {

    rlang::check_installed("slider")
    metrics_dots <- list2(...)
    date_var <- enquo(date_var)
    slider::slide_period_dfr(
        data,
        .i = data[[quo_name(date_var)]],
        .period = .period,
        .f = ~ tibble::tibble(
            !!date_var := min(.x[[quo_name(date_var)]]),
            n = nrow(.x),
            metric_set(.x, {{truth}}, {{estimate}}, !!!metrics_dots)
        ),
        .every = .every,
        .origin = .origin,
        .before = .before,
        .after = .after,
        .complete = .complete
    )

}

#' @rdname vetiver_compute_metrics
#' @export
vetiver_pin_metrics <- function(df_metrics,
                                date_var,
                                board,
                                metrics_pin_name,
                                initiate = FALSE) {
    date_var <- quo_name(enquo(date_var))

    if (initiate) {
        new_metrics <- vec_sort(df_metrics)
    } else {
        new_dates <- unique(df_metrics[[date_var]])
        old_metrics <- pins::pin_read(board, metrics_pin_name)
        old_metrics <- vec_slice(
            old_metrics,
            ! old_metrics[[date_var]] %in% new_dates
        )
        new_metrics <- vec_sort(vctrs::vec_rbind(old_metrics, df_metrics))
    }

    pins::pin_write(board, new_metrics, basename(metrics_pin_name))
    new_metrics

}


#' @rdname vetiver_compute_metrics
#' @export
vetiver_plot_metrics <- function(df_metrics,
                                 date_var,
                                 .estimate = .estimate,
                                 .metric = .metric,
                                 n = n) {
    rlang::check_installed("ggplot2")
    .metric <- enquo(.metric)

    ggplot2::ggplot(data = df_metrics,
                    ggplot2::aes({{ date_var }}, {{.estimate}})) +
        ggplot2::geom_line(ggplot2::aes(color = !!.metric), alpha = 0.7) +
        ggplot2::geom_point(ggplot2::aes(color = !!.metric,
                                         size = {{n}}),
                            alpha = 0.9) +
        ggplot2::facet_wrap(ggplot2::vars(!!.metric),
                            scales = "free_y", ncol = 1) +
        ggplot2::guides(color = "none") +
        ggplot2::labs(x = NULL, y = NULL)
}
