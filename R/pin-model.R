#' Pin a trained model to a board of models
#'
#' Use `pin_model()` to pin a trained model to a board of models, along with an
#' input prototype for new data and other model metadata.
#'
#' @param board A pin board, created by [pins::board_folder()],
#' [pins::board_rsconnect()], or other `board_` function from the pins package.
#' @param model A trained model, such as a modeling [workflows::workflow()].
#' @param model_id Model ID or name.
#' @param type Defaults to `"rds"`, which is appropriate for most models. (See
#' [pins::pin_write()] for other options.)
#' @param desc A text description of the model; most important for shared
#' boards so that others can understand what the model is. If omitted,
#' the package will generate a brief description of the contents.
#' @param versioned Should the model object be versioned? Defaults to `TRUE`.
#' @inheritParams pins::pin_write
#'
#' @details This function creates a pin on the specified `board` containing
#' two elements, the model object itself and the model's input data prototype.
#'
#' @export
pin_model <- function(board,
                      model,
                      model_id,
                      type = "rds",
                      desc = NULL,
                      metadata = NULL,
                      versioned = TRUE) {

    model_pinner(
        x = model,
        board = board,
        model_id = model_id,
        type = type,
        desc = desc,
        metadata = metadata,
        versioned = versioned
    )

}

#' Wrapper function for pinning a model to a board of models
#'
#' @param x A trained model
#' @param ... Other arguments passed from [`pin_model()`]
#'
#' @export
model_pinner <- function(x, ...)
    UseMethod("model_pinner")

#' @rdname model_pinner
#' @export
model_pinner.default <- function(x, ...)
    rlang::abort("There is no method available to pin `x`.")
