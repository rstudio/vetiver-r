#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param object A model API endpoint object created with [model_endpoint()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [httr::POST()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @importFrom stats predict
#' @method predict model_endpoint
#' @export predict.model_endpoint
#' @export
#'
#' @examples
#'
#' \dontrun{
#' endpoint <- model_endpoint("http://127.0.0.1:8088/predict")
#' predict(endpoint, mtcars[4:7, -1])
#' }
#'
#'
predict.model_endpoint <- function(object, new_data, ...) {
    data_json <- jsonlite::toJSON(new_data)
    ret <- httr::POST(object$url, ..., body = data_json)

    # TODO: make error messages better -- getting NULL for message?
    msg <- glue("predict: {httr::content(ret)[['message']]}")
    httr::stop_for_status(ret, task = msg)

    ret <- httr::content(ret, simplify = TRUE)
    tibble::as_tibble(ret)
}


#' Create a model API endpoint object for prediction
#'
#' @param url A trained model
#' @param ... Other arguments, not currently used.
#'
#' @examples
#'
#' \dontrun{
#' model_endpoint("https://colorado.rstudio.com/rsc/traffic-crashes/predict")
#' }
#'
#' @export
model_endpoint <- function(url, ...) {
    ret <- list(url = url)
    class(ret) <- "model_endpoint"
    ret
}

#' @export
print.model_endpoint <- function(x, ...) {
    cat("A model API endpoint for prediction:\n")
    cat(x$url)
}
