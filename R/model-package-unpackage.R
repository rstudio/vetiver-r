#' Package a trained model for writing to a board
#'
#' A developer-facing function that packages the trained model into a R object
#' ready to be written to a board. In most cases, the trained model will
#' already be in a R object that can be written to a board, however there are
#' some models that aren't R objects which would need to be packaged into a R 
#' object. For example, a model that is stored in a filesystem or a non-R
#' runtime that would need to be read or downloaded into a R object (e.g.
#' through readBin()`).
#'
#' @param model A trained model, such as an `lm()` model or a tidymodels
#'
#' @return a R object with the model that `pins::pin_write()` can write to a board
#'
#' @examples
#'
#' h2o::h2o.init()
#' splits <- datasets::mtcars |>
#'   h2o::as.h2o() |>
#'   h2o::h2o.splitFrame(ratios = c(0.6, 0.2), seed = 1)
#' train <- splits[[1]]
#' valid <- splits[[2]]
#' mtcars_gbm <- h2o::h2o.gbm(y = "mpg",
#'                            training_frame = train,
#'                            validation_frame = valid,
#'                            model_id = "mtcars_gbm",
#'                            seed = 1)
#' 
#' packaged_model <- model_package(mtcars_gbm)
#' pins::pin_write(board, packaged_model, name = 'mtcars_gbm')
#'
#' @rdname model_package
#' @export
model_package <- function(model) {
    UseMethod("model_package")
}

#' @rdname model_package
#' @export
model_package.default <- function(model) {
    model
}

#' Unpackage a trained model that was read from a board
#'
#' A developer-facing function that unpackages the trained model from a R
#' object, which was read from a board. In most cases, the R object read from
#' the board will already be the actual trained model, however there are some
#' models that aren't R objects and would need to be created from the R object.
#' For example, a model that needs to reside in a filesystem or a non-R
#' filesystem (e.g. through `writeBin()`).
#'
#' @param model A R object with the model, read from `pins::pin <- read()`
#'
#' @return a trained model from the R object such as an `lm()` model or a
#' tidymodels
#'
#' @examples
#'
#' h2o::h2o.init()
#' r_object <- pins::pin_read(board, 'mtcars_gbm')
#' model <- model_unpackage(r_object)
#' h2o::h2o.predict(model, input)
#'
#' @rdname model_unpackage
#' @export
model_unpackage <- function(model) {
    UseMethod("model_unpackage")
}

#' @rdname model_unpackage
#' @export
model_unpackage.default <- function(model) {
    model
}
