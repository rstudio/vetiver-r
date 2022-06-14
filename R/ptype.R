#' Create a vetiver input data prototype
#'
#' Optionally find and return an input data prototype for a model.
#'
#' @details
#' These are developer-facing functions, useful for supporting new model types.
#' A [vetiver_model()] object optionally stores an input data prototype for
#' checking at prediction time.
#'
#' - The default for `save_ptype`, `TRUE`, finds an input data prototype (a
#' zero-row slice of the training data) via [vetiver_ptype()].
#' - `save_ptype = FALSE` opts out of storing any input data prototype.
#' - You may pass your own data to `save_ptype`, but be sure to check that it
#' has the same structure as your training data, perhaps with
#' [hardhat::scream()].
#'
#' @inheritParams vetiver_model
#'
#' @return A `vetiver_ptype` method returns a zero-row dataframe, and
#' `vetiver_create_ptype()` returns either such a zero-row dataframe, `NULL`,
#' or the dataframe passed to `save_ptype`.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
#'
#' vetiver_create_ptype(cars_lm, TRUE)
#'
#' ## calls the right method for `model` via:
#' vetiver_ptype(cars_lm)
#'
#' ## can also turn off `ptype`
#' vetiver_create_ptype(cars_lm, FALSE)
#' @examplesIf rlang::is_installed("ranger")
#' ## some models require that you pass in training features
#' cars_rf <- ranger::ranger(mpg ~ ., data = mtcars)
#' vetiver_ptype(cars_rf, ptype_data = mtcars[,-1])
#'
#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype <- function(model, ...) {
    UseMethod("vetiver_ptype")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.default <- function(model, ...) {
    abort("There is no method available to create a 0-row input data prototype for `model`.")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_create_ptype <- function(model, save_ptype, ...) {
    if (isTRUE(save_ptype)) {
        ptype <- vetiver_ptype(model, ...)
    } else if (isFALSE(save_ptype)) {
        ptype <- NULL
    } else if (rlang::inherits_any(save_ptype, "data.frame")) {
        return(save_ptype)
    } else {
        abort("The `save_ptype` argument must be TRUE, FALSE, or a dataframe.")
    }
    ptype
}

check_ptype_data <- function(dots, call = rlang::caller_env()) {
    if (!rlang::has_name(dots, "ptype_data")) {
        abort(c("No `ptype_data` available to create an input data prototype",
                "Pass at least one row of training features as `ptype_data`",
                "See the documentation for `vetiver_ptype()`"),
              call = call)
    }
}

