#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param endpoint URL of a prediction endpoint, such as one created by
#' [`pr_model()`].
#' @param new_data New data for making predictions, such as a data frame.
#'
#' @return A tibble with as many rows as in `new_data` and model predictions.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' predict_api("http://127.0.0.1:4558/predict", mtcars[,2:11])
#' }
#'
#'
predict_api <- function(endpoint, new_data) {
    data_json <- jsonlite::toJSON(new_data)
    ret <- httr::POST(endpoint, body = data_json)

    # TODO: make error messages better -- getting NULL for message?
    msg <- glue("predict: {httr::content(ret)[['message']]}")
    httr::stop_for_status(ret, task = msg)

    ret <- httr::content(ret, simplify = TRUE)
    tibble::as_tibble(ret)
}
