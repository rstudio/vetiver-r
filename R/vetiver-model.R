#' Create a vetiver object for deployment of a trained model
#'
#' A `vetiver_model()` object collects the information needed to store, version,
#' and deploy a trained model. Once your `vetiver_model()` object has been
#' created, you can:
#' - store and version it as a pin with [vetiver_pin_write()]
#' - create an API endpoint for it with [vetiver_pr_predict()]
#'
#'
#' @param model A trained model, such as an `lm()` model or a tidymodels
#' [workflows::workflow()].
#' @param model_name Model name or ID.
#' @param description A detailed description of the model. If omitted, a brief
#' description of the model will be generated.
#' @param save_ptype Should an input data prototype be stored with the model?
#' The options are `TRUE` (the default, which stores a zero-row slice of the
#' training data), `FALSE` (no input data prototype for checking), or a
#' dataframe to be used for both checking at prediction time *and* examples in
#' API visual documentation.
#' @param ptype An input data prototype. If `NULL`, there is no checking of
#' new data at prediction time.
#' @param versioned Should the model object be versioned when stored with
#' [vetiver_pin_write()]? The default, `NULL`, will use the default for the
#' `board` where you store the model.
#' @param ... Other method-specific arguments passed to [vetiver_ptype()]
#' to compute an input data prototype.
#' @inheritParams pins::pin_write
#'
#' @details
#' You can provide your own data to `save_ptype` to use as examples in the
#' visual documentation created by [vetiver_pr_predict()]. If you do this,
#' consider checking that your input data prototype has the same structure
#' as your training data (perhaps with [hardhat::scream()]) and/or simulating
#' data to avoid leaking PII via your deployed model.
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
                          ...,
                          description = NULL,
                          metadata = list(),
                          save_ptype = TRUE,
                          versioned = NULL) {

    if (is_null(description)) {
        description <- vetiver_create_description(model)
    }
    ptype <- vetiver_create_ptype(model, save_ptype, ...)
    metadata <- vetiver_create_meta(model, metadata)
    model <- vetiver_prepare_model(model)

    new_vetiver_model(
        model = model,
        model_name = model_name,
        description = as.character(description),
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )
}

#' @rdname vetiver_model
#' @export
new_vetiver_model <- function(model,
                              model_name,
                              description,
                              metadata,
                              ptype,
                              versioned) {

    data <- list(
        model = model,
        model_name = model_name,
        description = description,
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )

    structure(data, class = "vetiver_model")
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


