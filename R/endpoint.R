#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param object A model API endpoint object created with [vetiver_endpoint()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [httr::POST()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @importFrom stats predict
#' @seealso [augment.vetiver_endpoint()]
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
    rlang::check_installed(c("jsonlite", "httr"))
    data_json <- jsonlite::toJSON(new_data, na = "string")
    ret <- httr::POST(object$url, ..., body = data_json)
    resp <- httr::content(ret, "text", encoding = "UTF-8")
    resp <- jsonlite::fromJSON(resp)

    if (httr::status_code(ret) >= 300) {
        if (has_name(resp, "message")) {
            abort(glue("Failed to predict: {resp$message}"))
        } else {
            status <- httr::http_status(ret)
            abort(c("Failed to predict.", status$message))
        }
    }

    tibble::as_tibble(resp)
}

#' Post new data to a deployed model API endpoint and augment with predictions
#'
#' @param x A model API endpoint object created with [vetiver_endpoint()].
#' @inheritParams predict.vetiver_endpoint
#'
#' @return The `new_data` with added prediction column(s).
#' @seealso [predict.vetiver_endpoint()]
#' @export
#'
#' @examples
#'
#' if (FALSE) {
#' endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
#' augment(endpoint, mtcars[4:7, -1])
#' }
#'
augment.vetiver_endpoint <- function(x, new_data, ...) {
    preds <- predict(x, new_data = new_data, ...)
    vctrs::vec_cbind(tibble::as_tibble(new_data), preds)
}


#' Create a model API endpoint object for prediction
#'
#' This function creates a model API endpoint for prediction from a URL. No
#' HTTP calls are made until you actually
#' [`predict()`][predict.vetiver_endpoint()] with your endpoint.
#'
#' @param url An API endpoint URL
#' @return A new `vetiver_endpoint` object
#'
#' @examples
#' vetiver_endpoint("https://colorado.rstudio.com/rsc/seattle-housing/predict")
#'
#' @export
vetiver_endpoint <- function(url) {
    url <- as.character(url)
    url <- gsub("/$", "", url)
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


