#' Write a trained model to a board of models
#'
#' Use `modelops_pin_write()` to pin a trained model to a board of models,
#' along with an input prototype for new data and other model metadata.
#'
#' @inheritParams modelops_pr_predict
#'
#' @details This function creates a pin on the specified `board` containing
#' the model object itself and other elements needed for prediction, such as
#' the model's input data prototype or which packages are needed at prediction
#' time. Use [pins::pin_read()] to retrieve the stored, versioned model by
#' name from the board.
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

