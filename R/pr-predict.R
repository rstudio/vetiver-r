#' Create a Plumber API to predict with a deployable `vetiver()` object
#'
#' Use `vetiver_pr_predict()` to add a POST endpoint for predictions from a
#' trained, pinned [vetiver()] object to a Plumber router.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param vetiver A deployable model object created with [vetiver()]
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @details First store and version your [vetiver()] object with
#' [vetiver_pin_write()], and then create an API endpoint with
#' `vetiver_pr_predict()`.
#'
#' Setting `debug = TRUE` may expose any sensitive data from your model in
#' API errors.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' m <- vetiver(cars_lm, "cars_linear", model_board)
#' vetiver_pin_write(m)
#'
#' library(plumber)
#' pr() %>% vetiver_pr_predict(m)
#' ## next, pipe to `pr_run()`
#'
#' @export
vetiver_pr_predict <- function(pr,
                               vetiver,
                               path = "/predict",
                               debug = interactive(),
                               ...) {

    handler_startup(vetiver)

    modify_spec <- function(spec) api_spec(spec, vetiver, path)

    pr <- plumber::pr_set_debug(pr, debug = debug)
    if (!is_null(vetiver$metadata$url)) {
        pr <- plumber::pr_get(pr,
                              path = "/pin-url",
                              function() vetiver$metadata$url)
    }
    pr <- plumber::pr_post(pr, path = path,
                           handler = handler_predict(vetiver, ...))
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    if (rlang::is_installed("rapidoc")) {
        pr <- plumber::pr_set_docs(
            pr,
            "rapidoc",
            heading_text = paste("vetiver", utils::packageVersion("vetiver"))
        )
    }
    pr
}

