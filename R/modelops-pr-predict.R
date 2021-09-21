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

    handler_startup(modelops)

    modify_spec <- function(spec) api_spec(spec, modelops, path)

    pr <- plumber::pr_set_debug(pr, debug = debug)
    if (!rlang::is_null(modelops$metadata$url)) {
        pr <- plumber::pr_get(pr,
                              path = "/pin-url",
                              function() modelops$metadata$url)
    }
    pr <- plumber::pr_post(pr, path = path,
                           handler = handler_predict(modelops, ...))
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    if (rlang::is_installed("rapidoc")) {
        pr <- plumber::pr_set_docs(pr, "rapidoc")
    }
    pr
}

