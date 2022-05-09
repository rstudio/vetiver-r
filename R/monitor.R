#' Aggregate, store, and plot model metrics over time for monitoring
#'
#' These three functions can be used in a model monitoring dashboard:
#' - `vetiver_aggregate_metrics()` computes metrics (such as accuracy for a
#' classification model or RMSE for a regression model) at a chosen time
#' aggregation `unit`
#' - `vetiver_pin_metrics()` updates (or creates) a pin storing model metrics
#' over time
#' - `plot_vetiver_metrics()` creates a plot of metrics over time
#'
#' @inheritParams yardstick::metrics
#' @inheritParams lubridate::floor_date
#' @param time_var
#' @param metric_set A [yarstick::metric_set()] function for computing metrics.
#' Defaults to [yardstick::metrics()].
#' @param df_metrics A tidy dataframe of metrics over time, such as created by
#' `vetiver_aggregate_metrics()`.
#' @param .estimate
#' @param .metric
#' @param n_validation
#'
#' @return
#'
#' @examples
#' @export
# maybe change to vetiver_compute_metrics
vetiver_aggregate_metrics <- function(data,
                                      time_var,
                                      unit,
                                      truth, estimate, ...,
                                      metric_set = yardstick::metrics) {

    time_var <- enquo(time_var)
    grouped_data <-
        data %>%
        mutate_if(is.character, as.factor) %>%
        mutate(
            "!!time_var" := lubridate::floor_date(as.Date(!!time_var),
                                                    unit = time_aggregation)
        ) %>%
        group_by(!!time_var)

    ## sliding function

    metrics_agg <-
        grouped_data %>%
        metric_set({{truth}}, {{estimate}}, ...)

    totals <-
        grouped_data %>%
        summarize(n_validation = n())

    metrics_agg %>% left_join(totals)
}

#' @rdname vetiver_aggregate_metrics
#' @export
vetiver_pin_metrics <- function(df_metrics,
                                time_var,
                                board,
                                metrics_pin_name,
                                initiate = FALSE) {


    old_metrics <- tibble()

    if (!initiate) {
        old_metrics <- pin_read(board, metrics_pin_name)
    }

    new_dates <- unique(pull(df_metrics, {{ time_var }}))

    new_metrics <- old_metrics %>%
        filter(!{{ time_var }} %in% new_dates) %>%
        bind_rows(df_metrics) %>%
        arrange(.metric, {{ time_var }})

    pin_write(board, new_metrics, basename(metrics_pin_name))

    new_metrics

}


#' @rdname vetiver_aggregate_metrics
#' @export
plot_vetiver_metrics <- function(df_metrics,
                                 time_var,
                                 .estimate = .estimate,
                                 .metric = .metric,
                                 n_validation = n_validation) {
    .metric <- enquo(.metric)

    ggplot(data = df_metrics, aes({{ time_var }}, {{.estimate}})) +
        geom_line(aes(color = !!.metric), alpha = 0.7) +
        geom_point(aes(color = !!.metric, size = {{n_validation}}), alpha = 0.9) +
        facet_wrap(vars(!!.metric), scales = "free_y", ncol = 1) +
        labs(x = NULL, y = NULL)
}
