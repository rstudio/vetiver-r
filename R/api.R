#' Add a POST endpoint to a Plumber router using a pinned model workflow object
#'
#' Models that have been pinned to a board with [`pin_model`] can be added to a
#' Plumber router as a POST handler. The argument `type` specifies what kind of
#' predictions the handler will return.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param board A board containing models pinned via [pin_model].
#' @param type A single character or `NULL` describing the type of prediction.
#' The specific pinned model must support the `type` requested. Some examples
#' of `type` for [workflows::workflow()] include "class", "prob", and "numeric".
#' When `NULL`, a default prediction type will be chosen based on the model
#' characteristics.
#' @param ... Other arguments passed to [plumber::pr_post()].
#' @inheritParams pin_model
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#'
#' model_board %>% pin_model(cars_lm, "cars")
#'
#' library(plumber)
#' pr() %>% pr_model(model_board, "cars")
#' ## next, pipe to `pr_run()`
#'
#' @importFrom glue glue
#' @export
pr_model <- function(pr,
                     board,
                     model_id,
                     type = NULL,
                     path = "/predict",
                     debug = interactive(),
                     ...) {

    board_pins <- pins::pin_list(board)
    if (!model_id %in% board_pins) {
        rlang::abort(glue("Model {model_id} not found"))
    }

    pinned <- pins::pin_read(board, model_id)

    handle_model(
        x = pinned$model,
        other_pinned = purrr::list_modify(pinned, model = model_id),
        meta = pins::pin_meta(board, model_id),
        pr = pr,
        type = type,
        path = path,
        debug = debug,
        ...
    )
}

#' Wrapper function for creating model handler function
#'
#' @param x A trained model
#' @param ... Other arguments passed from [pr_model()]
#'
#' @export
handle_model <- function(x, ...)
    UseMethod("handle_model")

#' @rdname handle_model
#' @export
handle_model.default <- function(x, ...)
    rlang::abort("There is no method available to build a model handler for `x`.")


#' @rdname handle_model
#' @export
handle_model.lm <- function(x, ...) {
    ellipsis::check_dots_used()
    args <- list(...)
    ptype <- args$other_pinned$ptype
    meta <- args$meta
    path <- args$path
    debug <- args$debug

    predict_handler <- function(req) {
        newdata <- req$body
        if (!rlang::is_null(ptype)) {
            newdata <- hardhat::scream(newdata, ptype)
        }
        ret <- predict(x, newdata = newdata, type = args$type)
        list(.pred = ret)
    }

    modify_spec <- function(spec) {
        api_spec(spec, args)
    }

    pr <- args$pr
    pr <- plumber::pr_set_debug(pr, debug = debug)
    ## pass more ... from args here after purrr::list_modify bug fixed?
    ## https://github.com/tidyverse/purrr/issues/826
    pr <- plumber::pr_post(pr, path = path, handler = predict_handler)
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr

}




