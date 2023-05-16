#' Read and write a trained model to a board of models
#'
#' Use `vetiver_pin_write()` to pin a trained model to a board of models,
#' along with an input prototype for new data and other model metadata. Use
#' `vetiver_pin_read()` to retrieve that pinned object.
#'
#' @inheritParams pins::pin_read
#' @inheritParams vetiver_api
#' @param check_renv Use [renv](https://rstudio.github.io/renv/) to record the
#' packages used at training time with `vetiver_pin_write()` and check for
#' differences with `vetiver_pin_read()`. Defaults to `FALSE`.
#'
#' @details These functions read and write a [vetiver_model()] pin on the
#' specified `board` containing the model object itself and other elements
#' needed for prediction, such as the model's input data prototype or which
#' packages are needed at prediction time. You may use [pins::pin_read()] or
#' [pins::pin_meta()] to handle the pin, but `vetiver_pin_read()` returns a
#' [vetiver_model()] object ready for deployment.
#'
#' @return `vetiver_pin_read()` returns a [vetiver_model()]; `vetiver_pin_write()`
#' returns the name of the new pin, invisibly.
#'
#' @examples
#' library(pins)
#' model_board <- board_temp()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(model_board, v)
#' model_board
#'
#' vetiver_pin_read(model_board, "cars_linear")
#'
#' # can use `version` argument to read a specific version:
#' pin_versions(model_board, "cars_linear")
#' @examplesIf interactive() || identical(Sys.getenv("IN_PKGDOWN"), "true")
#' # can store an renv lockfile as part of the pin:
#' vetiver_pin_write(model_board, v, check_renv = TRUE)
#'
#' @export
vetiver_pin_write <- function(board, vetiver_model, ..., check_renv = FALSE) {

    withr::local_options(list(renv.dynamic.enabled = FALSE))
    renv_lock <- NULL

    if (check_renv) {
        pkgs <- c(vetiver_model$metadata$required_pkgs, "vetiver")
        renv_lock <-
            renv$snapshot(
                lockfile = NULL,
                packages = pkgs,
                prompt = FALSE,
                force = TRUE
            )
    }

    metadata <- list_modify(
        vetiver_model$metadata$user,
        required_pkgs = vetiver_model$metadata$required_pkgs,
        renv_lock = renv_lock
    )

    pins::pin_write(
        board = board,
        x = list(model = vetiver_model$model,
                 prototype = vetiver_model$prototype),
        name = vetiver_model$model_name,
        type = "rds",
        description = vetiver_model$description,
        metadata = metadata,
        versioned = vetiver_model$versioned,
        ...
    )

    rlang::inform(
        c("\nCreate a Model Card for your published model",
          "Model Cards provide a framework for transparent, responsible reporting",
          "Use the vetiver `.Rmd` template as a place to start"),
        class = "model_card_nudge",
        .frequency = "once",
        .frequency_id = "model_card_nudge"
    )
}

#' @rdname vetiver_pin_write
#' @export
vetiver_pin_read <- function(board, name, version = NULL, check_renv = FALSE) {

    withr::local_options(list(renv.dynamic.enabled = FALSE))
    pinned <- pins::pin_read(board = board, name = name, version = version)
    meta   <- pins::pin_meta(board = board, name = name, version = version)
    required_pkgs <- meta$user$required_pkgs %||% pinned$required_pkgs

    if (check_renv) {
        if (length(meta$user$renv_lock) > 0) {
            local_lockfile <-
                renv$snapshot(
                    lockfile = NULL,
                    packages = c(required_pkgs, "vetiver"),
                    prompt = FALSE,
                    force = TRUE
                )
            orig_lockfile <- structure(meta$user$renv_lock, class = "renv_lockfile")
            renv_report_actions(local_lockfile, orig_lockfile)
        } else {
            cli::cli_warn(c(
                "There is no lockfile stored with {.val {name}}:",
                "i" = "Use {.arg check_renv = TRUE} when you save your model to your board"
            ))
        }
    }

    meta$user <- list_modify(meta$user, required_pkgs = zap(), renv_lock = zap())
    if (is_empty(meta$user)) names(meta$user) <- NULL

    new_vetiver_model(
        model = pinned$model,
        model_name = name,
        description = meta$description,
        metadata = vetiver_meta(
            user = meta$user,
            version = meta$local$version,
            url = meta$local$url,
            required_pkgs = required_pkgs
        ),
        prototype = pinned$prototype %||% pinned$ptype,
        versioned = board$versioned
    )
}


renv_report_actions <- function(current, model) {
    withr::local_options(
        list(renv.pretty.print.emitter = function(text, ...) {cli::cli_inform(text)})
    )
    diff <- renv$renv_lockfile_diff_packages(current, model)

    if (renv$empty(diff))
        return(invisible(NULL))

    lhs <- renv$renv_records(current)
    rhs <- renv$renv_records(model)
    renv$renv_pretty_print_records_pair(
        lhs[names(lhs) %in% names(diff)],
        rhs[names(rhs) %in% names(diff)],
        "The following package(s) do not match your model:",
        "Consider installing the same versions that your model was trained with."
    )

}

