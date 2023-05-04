#' Create a vetiver object for deployment of a trained model
#'
#' A `vetiver_model()` object collects the information needed to store, version,
#' and deploy a trained model. Once your `vetiver_model()` object has been
#' created, you can:
#' - store and version it as a pin with [vetiver_pin_write()]
#' - create an API endpoint for it with [vetiver_api()]
#'
#'
#' @param model A trained model, such as an `lm()` model or a tidymodels
#' [workflows::workflow()].
#' @param model_name Model name or ID.
#' @param description A detailed description of the model. If omitted, a brief
#' description of the model will be generated.
#' @param save_prototype Should an input data prototype be stored with the model?
#' The options are `TRUE` (the default, which stores a zero-row slice of the
#' training data), `FALSE` (no input data prototype for visual documentation or
#' checking), or a dataframe to be used for both checking at prediction time
#' *and* examples in API visual documentation.
#' @param save_ptype `r lifecycle::badge("deprecated")`
#' @param prototype An input data prototype. If `NULL`, there is no checking of
#' new data at prediction time.
#' @param versioned Should the model object be versioned when stored with
#' [vetiver_pin_write()]? The default, `NULL`, will use the default for the
#' `board` where you store the model.
#' @param ... Other method-specific arguments passed to [vetiver_ptype()]
#' to compute an input data prototype, such as `prototype_data` (a sample of
#' training features).
#' @inheritParams pins::pin_write
#'
#' @details
#' You can provide your own data to `save_prototype` to use as examples in the
#' visual documentation created by [vetiver_api()]. If you do this,
#' consider checking that your input data prototype has the same structure
#' as your training data (perhaps with [hardhat::scream()]) and/or simulating
#' data to avoid leaking PII via your deployed model.
#'
#' Some models, like [ranger::ranger()], [keras](https://tensorflow.rstudio.com/),
#' and [luz (torch)](https://torch.mlverse.org/),
#' *require* that you pass in example training data as `prototype_data`
#' or else explicitly set `save_prototype = FALSE`. For non-rectangular data
#' input to models, such as image input for a keras or torch model, we currently
#' recommend that you turn off prototype checking via `save_prototype = FALSE`.
#'
#' @return A new `vetiver_model` object.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' vetiver_model(cars_lm, "cars-linear")
#'
#' @export
vetiver_model <- function(model,
                          model_name,
                          ...,
                          description = NULL,
                          metadata = list(),
                          save_prototype = TRUE,
                          save_ptype = deprecated(),
                          versioned = NULL) {

    ellipsis::check_dots_used()
    if (lifecycle::is_present(save_ptype)) {
        lifecycle::deprecate_soft(
            "0.2.0",
            "vetiver_model(save_ptype)",
            "vetiver_model(save_prototype)"
        )
        save_prototype <- save_ptype
    }
    if (is_null(description)) {
        description <- vetiver_create_description(model)
    }
    prototype <- vetiver_create_ptype(model, save_prototype, ...)
    metadata <- vetiver_create_meta(model, metadata)
    model <- vetiver_prepare_model(model)

    new_vetiver_model(
        model = model,
        model_name = model_name,
        description = as.character(description),
        metadata = metadata,
        prototype = prototype,
        versioned = versioned
    )
}

#' @rdname vetiver_model
#' @export
new_vetiver_model <- function(model,
                              model_name,
                              description,
                              metadata,
                              prototype,
                              versioned) {

    data <- list(
        model = model,
        model_name = model_name,
        description = description,
        metadata = metadata,
        prototype = prototype,
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
        if (is.null(x$prototype)) {
            cli::cli_text("{x$description}")
        } else {
            cli::cli_text("{x$description} using {ncol(x$prototype)} feature{?s}")
        }
    })
}

#' @export
print.vetiver_model <- function(x, ...) {
    cat(format(x), sep = "\n")
    invisible(x)
}

#' @export
predict.vetiver_model <- function(object, ...) {
    ellipsis::check_dots_used()
    model <- bundle::unbundle(object$model)
    predict(model, ...)
}



#' @export
augment.vetiver_model <- function(x, ...) {
    ellipsis::check_dots_used()
    model <- bundle::unbundle(x$model)
    augment(model, ...)
}



