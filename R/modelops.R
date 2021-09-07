#' Create a modelops object for deployment of a trained model
#'
#' A `modelops()` object collects the information needed to store, version,
#' and deploy a trained model.
#'
#'
#' @param model A trained model, such as an `lm()` model or a tidymodels
#' [workflows::workflow()].
#' @param model_name Model name or ID.
#' @param board A pin board to store and version the `model`, created by
#' [pins::board_folder()], [pins::board_rsconnect()], or other `board_`
#' function from the pins package.
#' @param desc A text description of the model, most important for shared
#' boards so that others can understand what the model is. If omitted,
#' a brief description of the contents will be generated.
#' @param ptype Should an input data prototype be stored with the model?
#' The options are `TRUE` (the default, which stores a zero-row slice of the
#' training data), `FALSE` (no input data prototype for checking), or a
#' dataframe.
#' @param versioned Should the model object be versioned? Defaults to `TRUE`.
#' @param ... Other arguments, not currently used.
#' @inheritParams pins::pin_write
#'
#' @details  Once your `modelops()` object has been created, you can:
#' - store and version it as a pin with [modelops_pin_write()]
#' - create an API endpoint for it with [modelops_pr_predict()]
#'
#' If you provide your own data to `ptype`, consider checking that it has the
#' same structure as your training data (perhaps with [hardhat::scream()])
#' and/or simulating data to avoid leaking PII via your deployed model.
#'
#' @return A new `modelops` object
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' modelops(cars_lm, "cars_linear", pins::board_temp())
#'
#' @export
modelops <- function(model,
                     model_name,
                     board,
                     desc = NULL,
                     metadata = list(),
                     ptype = TRUE,
                     versioned = TRUE) {
    UseMethod("modelops")
}

#' @rdname modelops
#' @export
modelops.default <- function(model, ...) {
    rlang::abort("There is no modelops method available to deploy `model`.")
}

#' @rdname modelops
#' @export
modelops.lm <- function(model,
                        model_name,
                        board,
                        desc = NULL,
                        metadata = list(),
                        ptype = TRUE,
                        versioned = TRUE) {

    if (rlang::is_null(desc)) {
        desc <- "An OLS linear regression model"
    }

    ptype <- modelops_create_ptype(model, ptype)
    model <- butcher::butcher(model)

    new_modelops(
        model = model,
        model_name = model_name,
        board = board,
        desc = desc,
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )
}

#' @rdname modelops
#' @export
new_modelops <- function(model,
                         model_name = character(),
                         board = pins::board_temp(),
                         desc = character(),
                         metadata = list(),
                         ptype = TRUE,
                         versioned = TRUE) {

    data <- list(
        model = model,
        model_name = model_name,
        board = board,
        desc = desc,
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )

    structure(data, class = "modelops")
}

is_modelops <- function(x) {
    inherits(x, "modelops")
}

#' @export
format.modelops <- function(x, ...) {
    first_class <- class(x$model)[[1]]
    cli::cli_format_method({
        cli::cli_h3("{.emph {x$model_name}} {cli::symbol$line} {.cls {first_class}} model for deployment")
        cli::cli_text("{x$desc} using {dim(x$ptype)[[2]]} feature{?s}")
    })
}

#' @export
print.modelops <- function(x, ...) {
    cat(format(x, ...), sep = "\n")
    invisible(x)
}


