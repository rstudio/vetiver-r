#' Create a Plumber API to predict with a deployable `modelops()` object
#'
#' Use `modelops_pr_predict()` to add a POST endpoint for predictions from a
#' trained, pinned [modelops()] object to a Plumber router.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param modelops A deployable model object created with [modelops()]
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @details First store and version your [modelops()] object with
#' [modelops_pin_write()], and then create an API endpoint with
#' `modelops_pr_predict()`.
#'
#' Setting `debug = TRUE` may expose any sensitive data from your model in
#' API errors.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' m <- modelops(cars_lm, "cars_linear", model_board)
#' modelops_pin_write(m)
#'
#' library(plumber)
#' pr() %>% modelops_pr_predict(m)
#' ## next, pipe to `pr_run()`
#'
#' @export
modelops_pr_predict <- function(pr,
                                modelops,
                                path = "/predict",
                                debug = interactive(),
                                ...) {


    board_pins <- pins::pin_list(modelops$board)

    ## TODO: pin version checking here
    if (!modelops$model_name %in% board_pins) {
        rlang::abort(glue("Model {model_name} not found"))
    }

    pinned <- pins::pin_read(modelops$board, modelops$model_name)

    handler_startup(modelops)

    modify_spec <- function(spec) {
        api_spec(spec, modelops, path)
    }

    pr <- plumber::pr_set_debug(pr, debug = debug)
    pr <- plumber::pr_post(pr, path = path,
                           handler = handler_predict(modelops, ...))
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr
}

#' Model handler functions for API endpoint
#'
#' Each model supported by `modelops()` uses two handler functions
#' in [modelops_pr_predict()]:
#' - The `handler_startup` function executes when the API starts. Use this
#' function for tasks like loading packages. A model can use the default
#' method here, which is `NULL` (to do nothing at startup).
#' - The `handler_predict` function executes at each API call. Use this
#' function for calling `predict()` and any other tasks that must be executed
#' at each API call.
#'
#' @details These are two generics that use class of `modelops$model` for
#' dispatch.
#'
#' @inheritParams modelops_pr_predict
#'
#' @rdname handler_predict
#' @export
handler_startup <- function(modelops, ...)
    UseMethod("handler_startup", modelops$model)

#' @rdname handler_predict
#' @export
handler_startup.default <- function(modelops, ...) NULL

#' @rdname handler_predict
#' @export
handler_predict <- function(modelops, ...)
    UseMethod("handler_predict", modelops$model)

#' @rdname handler_predict
#' @export
handler_predict.default <- function(modelops, ...)
    rlang::abort("There is no method available to build a prediction handler for `x`.")


#' @rdname handler_predict
#' @export
handler_predict.lm <- function(modelops, ...) {

    ptype <- modelops$ptype

    function(req) {
        newdata <- req$body
        if (!rlang::is_null(ptype)) {
            newdata <- hardhat::scream(newdata, ptype)
        }
        ret <- predict(modelops$model, newdata = newdata, ...)
        list(.pred = ret)
    }

}




