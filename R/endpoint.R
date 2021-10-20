#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param object A model API endpoint object created with [vetiver_endpoint()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [httr::POST()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @importFrom stats predict
#' @export
#'
#' @examples
#'
#' if (FALSE) {
#' endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
#' predict(endpoint, mtcars[4:7, -1])
#' }
#'
#'
predict.vetiver_endpoint <- function(object, new_data, ...) {
    data_json <- jsonlite::toJSON(new_data)
    ret <- httr::POST(object$url, ..., body = data_json)
    resp <- httr::content(ret, "text", encoding = "UTF-8")
    ret <- jsonlite::fromJSON(resp)

    if (has_name(ret, "error")) {
        if (has_name(ret, "message")) {
            abort(glue("Failed to predict: {ret$message}"))
        } else {
            abort("Failed to predict")
        }
    }
    tibble::as_tibble(ret)
}


#' Create a model API endpoint object for prediction
#'
#' @param url An API endpoint URL
#' @return A new `vetiver_endpoint` object
#'
#' @examples
#' vetiver_endpoint("https://colorado.rstudio.com/rsc/biv_svm_api/predict")
#'
#' @export
vetiver_endpoint <- function(url) {
    url <- as.character(url)
    new_vetiver_endpoint(url)
}

new_vetiver_endpoint <- function(url = character()) {
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
    cat(format(x), sep = "\n")
    invisible(x)
}


