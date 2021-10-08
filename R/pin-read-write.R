#' Read and write a trained model to a board of models
#'
#' Use `vetiver_pin_write()` to pin a trained model to a board of models,
#' along with an input prototype for new data and other model metadata. Use
#' `vetiver_pin_read()` to retried that pinned object.
#'
#' @inheritParams vetiver_pr_predict
#' @inheritParams pins::pin_read
#'
#' @details These functions read and write a [vetiver_model()] pin on the
#' specified `board` containing the model object itself and other elements
#' needed for prediction, such as the model's input data prototype or which
#' packages are needed at prediction time. You may use [pins::pin_read()] or
#' [pins::pin_meta()] to handle the pin, but `vetiver_pin_read()` returns a
#' [vetiver_model()] object ready for deployment.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear", model_board)
#' vetiver_pin_write(v)
#' model_board
#'
#' vetiver_pin_read(model_board, "cars_linear")
#'
#' # can use `version` argument to read a specific version:
#' pin_versions(model_board, "cars_linear")
#'
#' @export
vetiver_pin_write <- function(vetiver_model) {
    pins::pin_write(
        board = vetiver_model$board,
        x = list(model = vetiver_model$model,
                 ptype = vetiver_model$ptype,
                 required_pkgs = vetiver_model$metadata$required_pkgs),
        name = vetiver_model$model_name,
        type = "rds",
        desc = vetiver_model$desc,
        metadata = vetiver_model$metadata$user,
        versioned = vetiver_model$versioned
    )
}

#' @rdname vetiver_pin_write
#' @export
vetiver_pin_read <- function(board, name, version = NULL) {

    pinned <- pins::pin_read(board = board, name = name, version = version)
    meta   <- pins::pin_meta(board = board, name = name, version = version)

    ## TODO: add subset of renv hash checking

    new_vetiver_model(
        model = pinned$model,
        model_name = name,
        board = board,
        desc = meta$description,
        metadata = vetiver_meta(
            user = meta$user,
            version = meta$local$version,
            url = meta$local$url,
            required_pkgs = pinned$required_pkgs
        ),
        ptype = pinned$ptype,
        versioned = board$versioned
    )
}
