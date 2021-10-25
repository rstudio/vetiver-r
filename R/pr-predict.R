#' Create a Plumber API to predict with a deployable `vetiver_model()` object
#'
#' Use `vetiver_pr_predict()` to add a POST endpoint for predictions from a
#' trained, pinned [vetiver_model()] to a Plumber router.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param vetiver_model A deployable [vetiver_model()] object
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @details First store and version your [vetiver_model()] with
#' [vetiver_pin_write()], and then create an API endpoint with
#' `vetiver_pr_predict()`.
#'
#' Setting `debug = TRUE` may expose any sensitive data from your model in
#' API errors.
#'
#' @return A Plumber router with the prediction endpoint added.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#'
#' library(plumber)
#' pr() %>% vetiver_pr_predict(v)
#' ## next, pipe to `pr_run()`
#'
#' @export
vetiver_pr_predict <- function(pr,
                               vetiver_model,
                               path = "/predict",
                               debug = is_interactive(),
                               ...) {
    # `force()` all `...` arguments early; https://github.com/tidymodels/vetiver/pull/20
    rlang::list2(...)
    loadNamespace("rapidoc")

    handler_startup(vetiver_model)

    modify_spec <- function(spec) api_spec(spec, vetiver_model, path)

    pr <- plumber::pr_set_debug(pr, debug = debug)
    if (!is_null(vetiver_model$metadata$url)) {
        pr <- plumber::pr_get(pr,
                              path = "/pin-url",
                              function() vetiver_model$metadata$url)
    }
    pr <- plumber::pr_post(pr, path = path,
                           handler = handler_predict(vetiver_model, ...))
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr <- plumber::pr_set_docs(
        pr, "rapidoc",
        heading_text = paste("vetiver", utils::packageVersion("vetiver"))
    )
    pr
}

