#' Create a vetiver input data prototype
#'
#' Optionally find and return an input data prototype for a model.
#'
#' @details
#' These are developer-facing functions, useful for supporting new model types.
#' A [vetiver_model()] object optionally stores an input data prototype for
#' checking at prediction time.
#'
#' - The default for `save_ptype`, `TRUE`, finds a zero-row slice of the
#' training data via [vetiver_slice_zero()].
#' - `save_ptype = FALSE` opts out of storing any input data prototype.
#' - You may pass your own data to `save_ptype`, but be sure to check that it
#' has the same structure as your training data, perhaps with
#' [hardhat::scream()].
#'
#' @inheritParams vetiver_model
#'
#' @return Either a zero-row dataframe, `NULL`, or the dataframe passed to
#' `save_ptype`.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
#'
#' vetiver_create_ptype(cars_lm, TRUE)
#'
#' ## calls the right method for `model` via:
#' vetiver_slice_zero(cars_lm)
#'
#' ## can also turn off `ptype`
#' vetiver_create_ptype(cars_lm, FALSE)
#'
#' @export
vetiver_create_ptype <- function(model, save_ptype, ...) {
    if (isTRUE(save_ptype)) {
        ptype <- vetiver_slice_zero(model, ...)
    } else if (isFALSE(save_ptype)) {
        ptype <- NULL
    } else if (rlang::inherits_any(save_ptype, "data.frame")) {
        return(save_ptype)
    } else {
        abort("The `save_ptype` argument must be TRUE, FALSE, or a dataframe.")
    }
    ptype
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_slice_zero <- function(model, ...) {
    UseMethod("vetiver_slice_zero")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_slice_zero.default <- function(model, ...) {
    abort("There is no method available to create a 0-row input data prototype for `model`.")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_slice_zero.lm <- function(model, ...) {
    pred_names <- attr(model$terms, "term.labels")
    ptype <- vctrs::vec_slice(model$model[pred_names], 0)
    tibble::as_tibble(ptype)
}



