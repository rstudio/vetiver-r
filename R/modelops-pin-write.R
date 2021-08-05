#' Write a trained model to a board of models
#'
#' Use `modelops_pin_write()` to pin a [modelops()] trained model object (plus
#' its input data prototype and other metadata) to a board of models.
#'
#' @inheritParams modelops_pin_router
#'
#' @details This function is used by [modelops_pin_router()] to create a pin
#' on the object's `board` containing the model object itself and other elements
#' needed for prediction, such as the model's input data prototype or which
#' packages are needed at prediction time. This function may also be used alone,
#' if you would like to *store* and *version* a model but not set up an API
#' endpoint.
#'
#' Use [pins::pin_read()] to retrieve the stored, versioned model by name from
#' the board.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' m <- modelops(cars_lm, "cars_linear", model_board)
#' modelops_pin_write(m)
#' model_board
#'
#' @export
modelops_pin_write <- function(modelops) {
    pins::pin_write(
        board = modelops$board,
        x = list(model = modelops$model, ptype = modelops$ptype),
        name = modelops$model_name,
        type = "rds",
        desc = modelops$desc,
        metadata = modelops$metadata,
        versioned = modelops$versioned
    )
}

