#' Model constructor methods
#'
#' These are developer-facing functions, useful for supporting new model types.
#' Each model supported by [`vetiver_model()`] uses four methods when the
#' deployable object is created:
#' - The `vetiver_prepare_model()` function executes first. Use this
#' function for tasks like checking if the model is trained. A model can use the
#' default method here, which is to return the model without changes (to do
#' nothing).
#' - The `vetiver_create_description()` function generates a helpful description
#' of the model based on its characteristics. This method is required.
#' - The [vetiver_create_meta()] function creates the correct [vetiver_meta()]
#' for the model. This is especially helpful for specifying which packages are
#' needing for prediction. A model can use the default method here, which is
#' to have no special metadata.
#' - The [vetiver_slice_zero()] function finds a zero-row slice of the
#' training data to use as an input data prototype at prediction time. This
#' method is required.
#'
#' @details These are four generics that use the class of `model` for dispatch.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' vetiver_prepare_model(cars_lm)
#' vetiver_create_description(cars_lm)
#'
#' @export
vetiver_prepare_model <- function(model, ...) {
    UseMethod("vetiver_prepare_model")
}

#' @rdname vetiver_prepare_model
#' @export
vetiver_prepare_model.default <- function(model, ...) {
    model
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_create_description <- function(model, ...) {
    UseMethod("vetiver_create_description")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_create_description.default <- function(model, ...) {
    abort("There is no method available to create a description for `model`.")
}
