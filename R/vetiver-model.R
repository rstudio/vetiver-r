#' Create a vetiver object for deployment of a trained model
#'
#' A `vetiver_model()` object collects the information needed to store, version,
#' and deploy a trained model.
#'
#'
#' @param model A trained model, such as an `lm()` model or a tidymodels
#' [workflows::workflow()].
#' @param model_name Model name or ID.
#' @param board A pin board to store and version the `model`, created by
#' [pins::board_folder()], [pins::board_rsconnect()], or other `board_*()`
#' function from the pins package.
#' @param description A detailed description of the model. If omitted, a brief
#' description of the model will be generated.
#' @param save_ptype Should an input data prototype be stored with the model?
#' The options are `TRUE` (the default, which stores a zero-row slice of the
#' training data), `FALSE` (no input data prototype for checking), or a
#' dataframe.
#' @param ptype An input data prototype. If `NULL`, there is no checking of
#' new data at prediction time.
#' @param versioned Should the model object be versioned? The default, `NULL`,
#' will use the default for `board`.
#' @param ... Other method-specific arguments passed to [vetiver_slice_zero()]
#' to compute an input data prototype.
#' @inheritParams pins::pin_write
#'
#' @details  Once your `vetiver_model()` object has been created, you can:
#' - store and version it as a pin with [vetiver_pin_write()]
#' - create an API endpoint for it with [vetiver_pr_predict()]
#'
#' If you provide your own data to `save_ptype`, consider checking that it has
#' the same structure as your training data (perhaps with [hardhat::scream()])
#' and/or simulating data to avoid leaking PII via your deployed model.
#'
#' @return A new `vetiver_model` object.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' vetiver_model(cars_lm, "cars_linear", pins::board_temp())
#'
#' @export
vetiver_model <- function(model,
                          model_name,
                          board,
                          ...,
                          description = NULL,
                          metadata = list(),
                          save_ptype = TRUE,
                          versioned = NULL) {
    UseMethod("vetiver_model")
}

#' @rdname vetiver_model
#' @export
vetiver_model.default <- function(model, ...) {
    abort("There is no `vetiver_model` method available to deploy `model`.")
}

#' @rdname vetiver_model
#' @export
vetiver_model.lm <- function(model,
                             model_name,
                             board,
                             ...,
                             description = NULL,
                             metadata = list(),
                             save_ptype = TRUE,
                             versioned = NULL) {

    if (is_null(description)) {
        description <- "An OLS linear regression model"
    }

    ptype <- vetiver_create_ptype(model, save_ptype, ...)
    model <- butcher::butcher(model)

    new_vetiver_model(
        model = model,
        model_name = model_name,
        board = board,
        description = description,
        metadata = vetiver_meta(metadata),
        ptype = ptype,
        versioned = versioned
    )
}

#' @rdname vetiver_model
#' @export
new_vetiver_model <- function(model,
                              model_name = character(),
                              board = pins::board_temp(),
                              ...,
                              description = character(),
                              metadata = vetiver::vetiver_meta(),
                              ptype = NULL,
                              versioned = NULL) {

    data <- list(
        model = model,
        model_name = model_name,
        board = board,
        description = description,
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )

    structure(data, class = "vetiver_model")
}


#' Metadata constructor for `vetiver_model()` object
#'
#' The metadata stored in a [vetiver_model()] object has three elements:
#'
#' - `$user`, the metadata supplied by the user
#' - `$version`, the version of the pin (which can be `NULL` before pinning)
#' - `$url`, the URL where the pin is located, if any
#' - `$required_pkgs`, a character string of R packages required for prediction
#'
#' @param user Metadata supplied by the user
#' @param version Version of the pin
#' @param url URL for the pin, if any
#' @param required_pkgs Character string of R packages required for prediction
#'
#' @return A list.
#' @examples
#' vetiver_meta()
#'
#' @export
vetiver_meta <- function(user = list(), version = NULL,
                         url = NULL, required_pkgs = NULL) {
    list(user = user, version = version,
         url = url, required_pkgs = required_pkgs)
}

is_vetiver_model <- function(x) {
    inherits(x, "vetiver_model")
}

#' @export
format.vetiver_model <- function(x, ...) {
    first_class <- class(x$model)[[1]]
    cli::cli_format_method({
        cli::cli_h3("{.emph {x$model_name}} {cli::symbol$line} {.cls {first_class}} model for deployment")
        cli::cli_text("{x$description} using {dim(x$ptype)[[2]]} feature{?s}")
    })
}

#' @export
print.vetiver_model <- function(x, ...) {
    cat(format(x), sep = "\n")
    invisible(x)
}


