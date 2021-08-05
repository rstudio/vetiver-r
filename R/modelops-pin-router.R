#' Create a Plumber API to predict with a deployable `modelops()` object
#'
#' Use `modelops_pin_router()` to pin a [modelops()] trained model object to a
#' board of models **and** set up a Plumber router with a POST endpoint for
#' predictions from the trained model.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param modelops A deployable model object created with [modelops()]
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @details Use [pins::pin_read()] to retrieve the stored, versioned model
#' from the pins board by name, if needed.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' m <- modelops(cars_lm, "cars_linear", model_board)
#'
#' library(plumber)
#' pr() %>% modelops_pin_router(m)
#' ## next, pipe to `pr_run()`
#'
#' @export
modelops_pin_router <- function(pr,
                                modelops,
                                path = "/predict",
                                debug = interactive(),
                                ...) {

    modelops_pin_write(modelops)  ## only do this once per deploy

    x <- modelops$model
    handler_startup(x, modelops)

    modify_spec <- function(spec) {
        api_spec(spec, modelops, path)
    }

    pr <- plumber::pr_set_debug(pr, debug = debug)
    pr <- plumber::pr_post(pr, path = path,
                           handler = handler_predict(x, modelops, ...))
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr
}

#' Model handler functions for API endpoint
#'
#' Each model supported by `modelops()` uses two handler functions
#' in [modelops_pin_router()]:
#' - The `handler_startup` function executes when the API starts. Use this
#' function for tasks like loading packages. A model can use the default
#' method here, which is `NULL` (to do nothing at startup).
#' - The `handler_predict` function executes at each API call. Use this
#' function for calling `predict()` and any other tasks that must be executed
#' at each API call.
#'
#' @param x A trained model stored in a [modelops()] object
#' @inheritParams modelops_pin_router
#'
#' @export
handler_startup <- function(x, ...)
    UseMethod("handler_startup")

#' @rdname handler_startup
#' @export
handler_startup.default <- function(x, ...) NULL

#' @rdname handler_startup
#' @export
handler_predict <- function(x, ...)
    UseMethod("handler_predict")

#' @rdname handler_startup
#' @export
handler_predict.default <- function(x, ...)
    rlang::abort("There is no method available to build a prediction handler for `x`.")


#' @rdname handler_startup
#' @export
handler_predict.lm <- function(x, modelops, ...) {

    ptype <- modelops$ptype

    function(req) {
        newdata <- req$body
        if (!rlang::is_null(ptype)) {
            newdata <- hardhat::scream(newdata, ptype)
        }
        ret <- predict(x, newdata = newdata, ...)
        list(.pred = ret)
    }

}




