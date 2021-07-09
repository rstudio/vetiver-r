#' Add a POST endpoint to a Plumber router using a pinned model workflow object
#'
#' Models that have been pinned to a board with [`pin_model`] can be added to a
#' Plumber router as a POST handler. The argument `type` specifies what kind of
#' predictions the handler will return.
#'
#' @param pr A Plumber router, such as from [`plumber::pr()`].
#' @param board A board containing models pinned via [`pin_model`].
#' @param type A single character or `NULL` describing the type of prediction.
#' The specific pinned model must support the `type` requested. Some examples
#' of `type` for [workflows::workflow()] include "class", "prob", and "numeric".
#' When `NULL`, a default prediction type will be chosen based on the model
#' characteristics.
#' @param ... Other arguments passed to [`plumber::pr_post()`].
#' @inheritParams pin_model
#' @inheritParams plumber::pr_post
#'
#' @export
pr_model <- function(pr,
                     board,
                     model_id,
                     type = NULL,
                     path = "/predict",
                     ...) {

    board_pins <- pins::pin_list(board)
    if (!model_id %in% board_pins) {
        rlang::abort(glue("Model {model_id} not found"))
    }

    pinned <- pins::pin_read(board, model_id)

    handle_model(
        x = pinned$model,
        other_pinned = purrr::list_modify(pinned, model = rlang::zap()),
        pr = pr,
        type = type,
        path = path,
        ...
    )
}

#' Wrapper function for creating model handler function
#'
#' @param x A trained model
#' @param ... Other arguments passed from [`pr_model()`]
#'
#' @export
handle_model <- function(x, ...)
    UseMethod("handle_model")

#' @rdname handle_model
#' @export
handle_model.default <- function(x, ...)
    rlang::abort("There is no method available to build a model handler for `x`.")




