#' Create a Plumber API to predict with a deployable `vetiver_model()` object
#'
#' Use `vetiver_api()` to add a POST endpoint for predictions from a
#' trained [vetiver_model()] to a Plumber router.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param vetiver_model A deployable [vetiver_model()] object
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @param check_ptype Should the `ptype` stored in `vetiver_model` (used for
#' visual API documentation) also be used to check new data at prediction time?
#' Defaults to `TRUE`.
#' @param all_docs Should the interactive visual API documentation be created
#' for _all_ POST endpoints in the router `pr`? This defaults to `TRUE`, and
#' assumes that all POST endpoints use the `vetiver_model$ptype` input data
#' prototype.
#' @inheritParams plumber::pr_post
#' @inheritParams plumber::pr_set_debug
#'
#' @details You can first store and version your [vetiver_model()] with
#' [vetiver_pin_write()], and then create an API endpoint with `vetiver_api()`.
#'
#' Setting `debug = TRUE` may expose any sensitive data from your model in
#' API errors.
#'
#' Two GET endpoints will also be added to the router `pr`, depending on the
#' characteristics of the model object: a `/pin-url` endpoint to return the
#' URL of the pinned model and a `/ping` endpoint for the API health.
#'
#' The function `vetiver_api()` uses:
#' - `vetiver_pr_post()` for endpoint definition and
#' - `vetiver_pr_docs()` to create visual API documentation
#'
#' These modular functions are available for more advanced use cases.
#'
#' @return A Plumber router with the prediction endpoint added.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#'
#' library(plumber)
#' pr() %>% vetiver_api(v)
#' ## is the same as:
#' pr() %>% vetiver_pr_post(v) %>% vetiver_pr_docs(v)
#' ## for either, next, pipe to `pr_run()`
#'
#' @export
vetiver_api <- function(pr,
                        vetiver_model,
                        path = "/predict",
                        debug = is_interactive(),
                        ...) {
    # `force()` all `...` arguments early; https://github.com/tidymodels/vetiver/pull/20
    rlang::list2(...)
    pr <- vetiver_pr_post(
        pr = pr,
        vetiver_model = vetiver_model,
        path = path,
        debug = debug,
        ...
    )

    pr <- vetiver_pr_docs(pr = pr, vetiver_model = vetiver_model, path = path)

    pr
}

#' @rdname vetiver_api
#' @export
vetiver_pr_post <- function(pr,
                            vetiver_model,
                            path = "/predict",
                            debug = is_interactive(),
                            ...,
                            check_ptype = TRUE) {
    # `force()` all `...` arguments early; https://github.com/tidymodels/vetiver/pull/20
    rlang::list2(...)
    handler_startup(vetiver_model)
    pr <- plumber::pr_set_debug(pr, debug = debug)
    pr <- plumber::pr_get(
        pr,
        path = "/ping",
        function() {list(status = "online", time = Sys.time())}
    )
    if (!is_null(vetiver_model$metadata$url)) {
        pr <- plumber::pr_get(
            pr,
            path = "/pin-url",
            function() vetiver_model$metadata$url
        )
    }
    if (!check_ptype) {
        vetiver_model$ptype <- NULL
    }
    pr <- plumber::pr_post(
        pr,
        path = path,
        handler = handler_predict(vetiver_model, ...)
    )

}

#' @rdname vetiver_api
#' @export
vetiver_pr_docs <- function(pr,
                            vetiver_model,
                            path = "/predict",
                            all_docs = TRUE) {
    loadNamespace("rapidoc")
    modify_spec <- function(spec) api_spec(spec, vetiver_model, path, all_docs)
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    logo <-
        '<img slot="logo" src="../logo/vetiver.png"
         width=55px style=\"margin-left:7px\"/>'
    pr <- plumber::pr_static(pr, "/logo", system.file(package = "vetiver"))
    pr <- plumber::pr_set_docs(
        pr,
        "rapidoc",
        slots = logo,
        heading_text = paste("vetiver", utils::packageVersion("vetiver")),
        header_color = "#F2C6AC",
        primary_color = "#8C2D2D"
    )
    pr
}

#' Create a Plumber API to predict with a deployable `vetiver_model()` object
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function was deprecated to use [vetiver_api] directly instead.
#'
#' @inheritParams vetiver_api
#' @export
#' @keywords internal
vetiver_pr_predict <- function(pr,
                               vetiver_model,
                               path = "/predict",
                               debug = is_interactive(),
                               ...) {

    lifecycle::deprecate_warn(
        "0.1.2",
        "vetiver_pr_predict()",
        "vetiver_api()"
    )

    # `force()` all `...` arguments early; https://github.com/tidymodels/vetiver/pull/20
    rlang::list2(...)
    vetiver_api(
        pr = pr,
        vetiver_model = vetiver_model,
        path = path,
        debug = debug,
        ...,
        docs = TRUE
    )
}
