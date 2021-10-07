#' Model handler functions for API endpoint
#'
#' Each model supported by `vetiver_model()` uses two handler functions
#' in [vetiver_pr_predict()]:
#' - The `handler_startup` function executes when the API starts. Use this
#' function for tasks like loading packages. A model can use the default
#' method here, which is `NULL` (to do nothing at startup).
#' - The `handler_predict` function executes at each API call. Use this
#' function for calling `predict()` and any other tasks that must be executed
#' at each API call.
#'
#' @details These are two generics that use the class of `vetiver_model$model`
#' for dispatch.
#'
#' @inheritParams vetiver_pr_predict
#'
#' @rdname handler_predict
#' @export
handler_startup <- function(vetiver_model, ...)
    UseMethod("handler_startup", vetiver_model$model)

#' @rdname handler_predict
#' @export
handler_startup.default <- function(vetiver_model, ...) NULL

#' @rdname handler_predict
#' @export
handler_predict <- function(vetiver_model, ...)
    UseMethod("handler_predict", vetiver_model$model)

#' @rdname handler_predict
#' @export
handler_predict.default <- function(vetiver_model, ...)
    abort("There is no method available to build a prediction handler for `x`.")


#' @rdname handler_predict
#' @export
handler_predict.lm <- function(vetiver_model, ...) {

    ptype <- vetiver_model$ptype

    function(req) {
        newdata <- req$body
        newdata <- vetiver_type_convert(newdata, ptype)
        if (!is_null(ptype)) {
            newdata <- hardhat::scream(newdata, ptype)
        }
        ret <- predict(vetiver_model$model, newdata = newdata, ...)
        list(.pred = ret)
    }

}


#' Convert new data at prediction time using input data prototype
#'
#' This is a developer-facing function, useful for supporting new model types.
#' At prediction time, new observations typically must be checked and sometimes
#' converted to the data types from training time.
#'
#' @examples
#'
#' library(tibble)
#' training_df <- tibble(x = as.Date("2021-01-01") + 0:9,
#'                       y = LETTERS[1:10], z = letters[11:20])
#' training_df
#'
#' ptype <- vctrs::vec_slice(training_df, 0)
#' vetiver_type_convert(tibble(x = "2021-02-01", y = "J", z = "k"), ptype)
#'
#'
#' @inheritParams predict.vetiver_endpoint
#' @param ptype An input data prototype, such as a 0-row slice of the training
#' data
#' @export
vetiver_type_convert <- function(new_data, ptype) {
    if (!is_null(ptype)) {
        spec <- readr::as.col_spec(ptype)
        is_character <- vapply(new_data, is.character, logical(1))
        if (any(is_character)) {
            new_data <- readr::type_convert(new_data, col_types = spec)
        }
    }
    new_data
}


