#' Create a Plumber API to predict with a deployable `vetiver_model()` object
#'
#' Use `vetiver_api()` to add a POST endpoint for predictions from a
#' trained [vetiver_model()] to a Plumber router.
#'
#' @param pr A Plumber router, such as from [plumber::pr()].
#' @param vetiver_model A deployable [vetiver_model()] object
#' @param ... Other arguments passed to `predict()`, such as prediction `type`
#' @param check_prototype Should the input data prototype stored in
#' `vetiver_model` (used for visual API documentation) also be used to check
#' new data at prediction time? Defaults to `TRUE`.
#' @param check_ptype `r lifecycle::badge("deprecated")`
#' @param all_docs Should the interactive visual API documentation be created
#' for _all_ POST endpoints in the router `pr`? This defaults to `TRUE`, and
#' assumes that all POST endpoints use the [vetiver_model()] input data
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
#' @examplesIf rlang::is_installed("plumber")
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
    vetiver_model$model <- bundle::unbundle(vetiver_model$model)
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
                            check_prototype = TRUE,
                            check_ptype = deprecated()) {
    rlang::check_installed("plumber")
    # `force()` all `...` arguments early; https://github.com/tidymodels/vetiver/pull/20
    rlang::list2(...)

    if (lifecycle::is_present(check_ptype)) {
        lifecycle::deprecate_soft(
            "0.2.0",
            "vetiver_pr_post(check_ptype)",
            "vetiver_pr_post(check_prototype)"
        )
        check_prototype <- check_ptype
    }

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
    if (!check_prototype) {
        vetiver_model$prototype <- NULL
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
    rlang::check_installed("plumber")
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
    lifecycle::deprecate_stop(
        "0.1.2",
        "vetiver_pr_predict()",
        "vetiver_api()"
    )
}


local_plumber_session <- function(pr, port, docs = FALSE, env = parent.frame()) {
    rlang::check_installed("plumber")
    rs <- callr::r_session$new()
    rs$call(
        function(pr, port, docs) {
            plumber::pr_run(pr = pr, port = port, docs = docs)
        },
        args = list(pr = pr, port = port, docs = docs)
    )
    withr::defer(rs$close(), envir = env)
    rs
}
