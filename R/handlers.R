#' Model handler functions for API endpoint
#'
#' These are developer-facing functions, useful for supporting new model types.
#' Each model supported by `vetiver_model()` uses two handler functions
#' in [vetiver_api()]:
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
#' @inheritParams vetiver_api
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' handler_startup(v)
#' handler_predict(v)
#'
#' @return A `handler_startup` function should return invisibly, while a
#' `handler_predict` function should return a function with the signature
#' `function(req)`. The request body (`req$body`) consists of the new data
#' at prediction time; this function should return predictions either as a
#' tibble or as a list coercable to a tibble via [tibble::as_tibble()].
#' @rdname handler_startup
#' @export
handler_startup <- function(vetiver_model)
    UseMethod("handler_startup", vetiver_model$model)

#' @rdname handler_startup
#' @export
handler_startup.default <- function(vetiver_model) invisible(NULL)

#' @rdname handler_startup
#' @export
handler_predict <- function(vetiver_model, ...)
    UseMethod("handler_predict", vetiver_model$model)

#' @rdname handler_startup
#' @export
handler_predict.default <- function(vetiver_model, ...)
    abort("There is no method available to build a prediction handler for `x`.")

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
#' prototype <- vctrs::vec_slice(training_df, 0)
#' vetiver_type_convert(tibble(x = "2021-02-01", y = "J", z = "k"), prototype)
#'
#' ## unsuccessful conversion generates an error:
#' try(vetiver_type_convert(tibble(x = "potato", y = "J", z = "k"), prototype))
#'
#' ## error for missing column:
#' try(vetiver_type_convert(tibble(x = "potato", y = "J"), prototype))
#'
#' @inheritParams predict.vetiver_endpoint
#' @param ptype An input data prototype, such as a 0-row slice of the training
#' data
#' @return A converted dataframe
#' @export
vetiver_type_convert <- function(new_data, ptype) {
    new_data <- hardhat::validate_column_names(new_data, colnames(ptype))
    spec <- readr::as.col_spec(ptype)
    is_character <- vapply(new_data, is.character, logical(1))
    if (any(is_character)) {
        new_data <- type_convert_strict(new_data, col_types = spec)
    }
    new_data
}

type_convert_strict <- function(new_data, col_types) {
    warn_to_error <- function(e) {
        abort(conditionMessage(e))
    }

    tryCatch(
        warning = function(e) warn_to_error(e),
        expr = readr::type_convert(new_data, col_types = col_types)
    )
}
