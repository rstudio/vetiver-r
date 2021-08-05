#' Add a POST endpoint to a Plumber router with a deployable `modelops()` object
#'
#' Deployable [modelops()] objects can be added to a Plumber router as a POST
#' handler. The argument `type` specifies what kind of predictions the handler
#' will return.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param modelops A deployable model object created with [modelops()].
#' @param type A single character or `NULL` describing the type of prediction.
#' The specific pinned model must support the `type` requested. Some examples
#' of `type` for [workflows::workflow()] include "class", "prob", and "numeric".
#' When `NULL`, a default prediction type will be chosen based on the model
#' characteristics.
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' m <- modelops(cars_lm, "cars_linear", model_board)
#'
#' library(plumber)
#' pr() %>% modelops_pr_deploy(m)
#' ## next, pipe to `pr_run()`
#'
#' @importFrom rlang is_null
#' @importFrom rlang is_function
#' @export
modelops_pr_deploy <- function(pr,
                               modelops,
                               type = NULL,
                               path = "/predict",
                               debug = interactive()) {

    modelops_pin_write(modelops)  ## only do this once per deploy

    handler_info <- handle_model(
        x = modelops$model,
        other = purrr::list_modify(modelops, model = rlang::zap()), ## not actually zapping because of purrr bug
        type = type
    )

    if (is_function(handler_info$on_start)) {
        on_start <- handler_info$on_start
        on_start()
    } else if (!is_null(handler_info$on_start)) {
        rlang::abort("`on_start` must be `NULL` or a function.")
    }

    if (!is_function(handler_info$handler)) {
        rlang::abort("`handler` must be a function.")
    }

    modify_spec <- function(spec) {
        api_spec(spec, modelops, path)
    }

    pr <- plumber::pr_set_debug(pr, debug = debug)
    ## pass more ... from args here after purrr::list_modify bug fixed?
    ## https://github.com/tidyverse/purrr/issues/826
    pr <- plumber::pr_post(pr, path = path, handler = handler_info$handler)
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr
}

#' Wrapper function for creating model handler functions
#'
#' The `handle_model()` function for each model type returns a list of
#' functions:
#' - The `on_start` function executes when the API starts. Use this function
#' for tasks like loading packages.
#' - The `handler` function executes at each API call. Use this function for
#' calling `predict()` and other tasks that must be executed at each API call.
#'
#' @param x A trained model stored in a [modelops()] object
#' @param other Other components of a [modelops()] object
#' @param ... Other arguments, not currently used.
#' @inheritParams modelops_pr_deploy
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
handle_model.lm <- function(x, other, type) {

    ptype <- other$ptype

    list(
        on_start = NULL,
        handler = function(req) {
            newdata <- req$body
            if (!rlang::is_null(ptype)) {
                newdata <- hardhat::scream(newdata, ptype)
            }
            ret <- predict(x, newdata = newdata, type = type)
            list(.pred = ret)
        }
    )

}




