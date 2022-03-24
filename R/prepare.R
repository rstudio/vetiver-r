#' Model constructor methods
#'
#' These are developer-facing functions, useful for supporting new model types.
#' Each model supported by [`vetiver_model()`] uses up to four methods when the
#' deployable object is created:
#' - The `vetiver_create_description()` function generates a helpful description
#' of the model based on its characteristics. This method is required.
#' - The [vetiver_create_meta()] function creates the correct [vetiver_meta()]
#' for the model. This is especially helpful for specifying which packages are
#' needed for prediction. A model can use the default method here, which is
#' to have no special metadata.
#' - The [vetiver_ptype()] function finds an input data prototype from the
#' training data (a zero-row slice) to use for checking at prediction time.
#' This method is required.
#' - The `vetiver_prepare_model()` function executes last. Use this function
#' for tasks like checking if the model is trained and reducing the size of the
#' model via [butcher::butcher()]. A model can use the default method here,
#' which is to return the model without changes.
#'
#' @inheritParams vetiver_model
#' @details These are four generics that use the class of `model` for dispatch.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' vetiver_create_description(cars_lm)
#' vetiver_prepare_model(cars_lm)
#'
#' @rdname vetiver_create_description
#' @export
vetiver_create_description <- function(model) {
    UseMethod("vetiver_create_description")
}

#' @rdname vetiver_create_description
#' @export
vetiver_create_description.default <- function(model) {
    abort("There is no method available to create a description for `model`.")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model <- function(model) {
    UseMethod("vetiver_prepare_model")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.default <- function(model) {
    model
}
