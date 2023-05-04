#' Create a vetiver input data prototype
#'
#' Optionally find and return an input data prototype for a model.
#'
#' @details
#' These are developer-facing functions, useful for supporting new model types.
#' A [vetiver_model()] object optionally stores an input data prototype for
#' checking at prediction time.
#'
#' - The default for `save_prototype`, `TRUE`, finds an input data prototype (a
#' zero-row slice of the training data) via [vetiver_ptype()].
#' - `save_prototype = FALSE` opts out of storing any input data prototype.
#' - You may pass your own data to `save_prototype`, but be sure to check that it
#' has the same structure as your training data, perhaps with
#' [hardhat::scream()].
#'
#' @inheritParams vetiver_model
#'
#' @return A `vetiver_ptype` method returns a zero-row dataframe, and
#' `vetiver_create_ptype()` returns either such a zero-row dataframe, `NULL`,
#' or the dataframe passed to `save_prototype`.
#'
#' @examples
#'
#' cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
#'
#' vetiver_create_ptype(cars_lm, TRUE)
#'
#' ## calls the right method for `model` via:
#' vetiver_ptype(cars_lm)
#'
#' ## can also turn off prototype
#' vetiver_create_ptype(cars_lm, FALSE)
#' @examplesIf rlang::is_installed("ranger")
#' ## some models require that you pass in training features
#' cars_rf <- ranger::ranger(mpg ~ ., data = mtcars)
#' vetiver_ptype(cars_rf, prototype_data = mtcars[,-1])
#'
#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype <- function(model, ...) {
    UseMethod("vetiver_ptype")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.default <- function(model, ...) {
    abort("There is no method available to create a 0-row input data prototype for `model`.")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_create_ptype <- function(model, save_prototype, ...) {
    ellipsis::check_dots_used()
    if (isTRUE(save_prototype)) {
        ptype <- vetiver_ptype(model, ...)
    } else if (isFALSE(save_prototype)) {
        ptype <- NULL
    } else if (rlang::inherits_any(save_prototype, "data.frame")) {
        return(save_prototype)
    } else {
        abort("The `save_prototype` argument must be TRUE, FALSE, or a dataframe.")
    }
    ptype
}

check_ptype_data <- function(dots, call = rlang::caller_env()) {
    if (!rlang::has_name(dots, "prototype_data")) {
        abort(c("No `prototype_data` available to create an input data prototype",
                "Pass at least one row of training features as `prototype_data`",
                "See the documentation for `vetiver_ptype()`"),
              call = call)
    }
}


preds_lm_ish <- function(model) {
    .terms <- terms(model)
    terms_matrix <- attr(.terms, "factors")
    terms_names <- colnames(terms_matrix)
    terms_exprs <- parse_exprs(terms_names)
    has_interactions <- map_lgl(terms_exprs, expr_contains, what = as.name(":"))
    terms_names[!has_interactions]
}

expr_contains <- function(expr, what) {
    switch(typeof(expr),
           symbol = identical(expr, what),
           call = call_contains(expr, what),
           language = call_contains(expr, what),
           FALSE
    )
}

call_contains <- function(expr, what) {
    if (length(expr) == 0L) {
        abort("Internal error, `expr` should be at least length 1.")
    }

    # Recurse into elements
    contains <- map_lgl(as.list(expr), expr_contains, what = what)
    any(contains)
}

