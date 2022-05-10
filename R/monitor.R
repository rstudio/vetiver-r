#' Aggregate, store, and plot model metrics over time for monitoring
#'
#' These three functions can be used for model monitoring (such as in a
#' monitoring dashboard):
#' - `vetiver_compute_metrics()` computes metrics (such as accuracy for a
#' classification model or RMSE for a regression model) at a chosen time
#' aggregation `unit`
#' - `vetiver_pin_metrics()` updates (or creates) a pin storing model metrics
#' over time
#' - `vetiver_plot_metrics()` creates a plot of metrics over time
#'
#' @inheritParams yardstick::metrics
#' @inheritParams lubridate::floor_date
#' @inheritParams pins::pin_read
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
#' Chicago <- Chicago %>% select(ridership, date, one_of(stations))
#' training_data <- Chicago %>% filter(date < "2008-12-31")
#' testing_data <- Chicago %>% filter(date > "2009-01-01", date < "2010-12-31")
#' monitoring <- Chicago %>% filter(date > "2011-01-01", date < "2012-12-31")
#' lm_fit <- linear_reg() %>% fit(ridership ~ ., data = training_data)
#'
#' library(pins)
#' b <- board_temp()
#'
#' ## before starting monitoring, initiate the metrics and pin
#' ## (for example, with the testing data):
#' original_metrics <-
#'     augment(lm_fit, new_data = testing_data) %>%
#'     vetiver_compute_metrics(date, "month", ridership, .pred) %>%
#'     vetiver_pin_metrics(date, b, "lm_fit_metrics", initiate = TRUE)
#'
#' ## to continue monitoring with new data, compute metrics and update pin:
#' new_metrics <-
#'     augment(lm_fit, new_data = monitoring) %>%
#'     vetiver_compute_metrics(date, "month", ridership, .pred) %>%
#'     vetiver_pin_metrics(date, b, "lm_fit_metrics")
#'
#' library(ggplot2)
#' vetiver_plot_metrics(new_metrics, date) +
#'     scale_size(range = c(2, 4))
#'
#' @export
vetiver_compute_metrics <- function(data,
                                    date_var,
                                    unit,
                                    truth, estimate, ...,
                                    metric_set = yardstick::metrics) {
    rlang::check_installed("dplyr")
    date_var <- enquo(date_var)

    grouped_data <-
        data %>%
        dplyr::mutate_if(is.character, as.factor) %>%
        dplyr::mutate(
            !!date_var := lubridate::floor_date(as.Date(!!date_var), unit = unit)
        ) %>%
        dplyr::group_by(!!date_var)

    ## sliding function

    metrics_agg <- metric_set(grouped_data, {{truth}}, {{estimate}}, ...)
    totals <- dplyr::summarize(grouped_data, n = n())
    dplyr::left_join(metrics_agg, totals, by = rlang::quo_name(date_var))
}

#' @rdname vetiver_compute_metrics
#' @export
vetiver_pin_metrics <- function(df_metrics,
                                date_var,
                                board,
                                metrics_pin_name,
                                initiate = FALSE) {

    rlang::check_installed("dplyr")
    if (initiate) {
        new_metrics <- dplyr::arrange(df_metrics, .metric, {{ date_var }})
    } else {
        new_dates <- unique(dplyr::pull(df_metrics, {{ date_var }}))
        old_metrics <-
            pins::pin_read(board, metrics_pin_name) %>%
            dplyr::filter(!{{ date_var }} %in% new_dates)
        new_metrics <-
            dplyr::bind_rows(old_metrics, df_metrics) %>%
            dplyr::arrange(.metric, {{ date_var }})
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
