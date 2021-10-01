#' Return a modelops input data prototype
#'
#' These are developer-facing functions, useful for supporting new model types.
#' A [modelops()] object optionally stores an input data prototype for checking
#' at prediction time.
#'
#' - The default, `TRUE`, finds a zero-row slice of the training data via
#' [modelops_slice_zero()].
#' - `FALSE` opts out of storing any input data prototype.
#' - You may pass your own data to `ptype`, but be sure to check that it has
#' the same structure as your training data, perhaps with [hardhat::scream()].
#'
#' @inheritParams modelops
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
#'
#' modelops_create_ptype(cars_lm, TRUE)
#'
#' ## calls the right method for `model` via:
#' modelops_slice_zero(cars_lm)
#'
#' ## can also turn off `ptype`
#' modelops_create_ptype(cars_lm, FALSE)
#'
#' @export
modelops_create_ptype <- function(model, ptype, ...) {
    if (isTRUE(ptype)) {
        ptype <- modelops_slice_zero(model, ...)
    } else if (isFALSE(ptype)) {
        ptype <- NULL
    } else if (rlang::inherits_any(ptype, "data.frame")) {
        return(ptype)
    } else {
        rlang::abort("The `ptype` argument must be TRUE, FALSE, or a dataframe.")
    }
    ptype
}

#' @rdname modelops_create_ptype
#' @export
modelops_slice_zero <- function(model, ...) {
    UseMethod("modelops_slice_zero")
}

#' @rdname modelops_create_ptype
#' @export
modelops_slice_zero.default <- function(model, ...) {
    rlang::abort("There is no method available to create a 0-row input data prototype for `model`.")
}

#' @rdname modelops_create_ptype
#' @export
modelops_slice_zero.lm <- function(model, ...) {
    pred_names <- attr(model$terms, "term.labels")
    ptype <- vctrs::vec_slice(model$model[pred_names], 0)
    tibble::as_tibble(ptype)
}



