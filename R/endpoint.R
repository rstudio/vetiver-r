#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param object A model API endpoint object created with [vetiver_endpoint()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [httr::POST()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @importFrom stats predict
#' @method predict vetiver_endpoint
#' @export predict.vetiver_endpoint
#' @export
#'
#' @examples
#'
#' \dontrun{
#' endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
#' predict(endpoint, mtcars[4:7, -1])
#' }
#'
#'
predict.vetiver_endpoint <- function(object, new_data, ...) {
    data_json <- jsonlite::toJSON(new_data)
    ret <- httr::POST(object$url, ..., body = data_json)

    msg <- httr::content(ret)[['message']]
    glue_msg <- ifelse(rlang::is_null(msg), "predict", glue("predict: {msg}"))
    httr::stop_for_status(ret, task = glue_msg)

    ret <- httr::content(ret, simplify = TRUE)
    tibble::as_tibble(ret)
}


#' Create a model API endpoint object for prediction
#'
#' @param url An API endpoint URL
#' @param ... Other arguments, not currently used
#' @return A new `vetiver_endpoint` object
#'
#' @examples
#' vetiver_endpoint("https://colorado.rstudio.com/rsc/biv_svm_api/predict")
#'
#' @export
vetiver_endpoint <- function(url, ...) {
    url <- as.character(url)
    new_vetiver_endpoint(url, ...)
}

new_vetiver_endpoint <- function(url = character(), ...) {
    stopifnot(is.character(url))
    structure(list(url = url), class = "vetiver_endpoint")
}

#' @export
format.vetiver_endpoint <- function(x, ...) {
    cli::cli_format_method({
        cli::cli_h3("A model API endpoint for prediction:")
        cli::cli_text("{x$url}")
    })
}

#' @export
print.vetiver_endpoint <- function(x, ...) {
    cat(format(x, ...), sep = "\n")
    invisible(x)
}


