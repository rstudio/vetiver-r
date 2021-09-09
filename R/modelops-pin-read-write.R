#' Read and write a trained model to a board of models
#'
#' Use `modelops_pin_write()` to pin a trained model to a board of models,
#' along with an input prototype for new data and other model metadata. Use
#' `modelops_pin_read()` to retried that pinned object.
#'
#' @inheritParams modelops_pr_predict
#' @inheritParams pins::pin_read
#'
#' @details These functions read and write a [modelops()] pin on the specified
#' `board` containing the model object itself and other elements needed for
#' prediction, such as the model's input data prototype or which packages are
#' needed at prediction time. You may use [pins::pin_read()] or
#' [pins::pin_meta()] to handle the pin, but `modelops_pin_read()` returns a
#' [modelops()] object ready for deployment.
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
#' modelops_pin_read(model_board, "cars_linear")
#'
#' # can use `version` argument to read a specific version:
#' pin_versions(model_board, "cars_linear")
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

#' @rdname modelops_pin_write
#' @export
modelops_pin_read <- function(board, name, version = NULL) {

    pinned <- pins::pin_read(board = board, name = name, version = version)
    meta   <- pins::pin_meta(board = board, name = name, version = version)

    ## add subset of renv hash checking

    new_modelops(
        model = pinned$model,
        model_name = name,
        board = board,
        desc = meta$description,
        ptype = pinned$ptype
    )
}

