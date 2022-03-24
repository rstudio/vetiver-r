#' Metadata constructors for `vetiver_model()` object
#'
#' These are developer-facing functions, useful for supporting new model types.
#' The metadata stored in a [vetiver_model()] object has four elements:
#' - `$user`, the metadata supplied by the user
#' - `$version`, the version of the pin (which can be `NULL` before pinning)
#' - `$url`, the URL where the pin is located, if any
#' - `$required_pkgs`, a character string of R packages required for prediction
#'
#' @inheritParams vetiver_model
#' @param user Metadata supplied by the user
#' @param version Version of the pin
#' @param url URL for the pin, if any
#' @param required_pkgs Character string of R packages required for prediction
#'
#' @return The `vetiver_meta()` constructor returns a list. The
#' `vetiver_create_meta` function returns a `vetiver_meta()` list.
#'
#' @examples
#' vetiver_meta()
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' vetiver_create_meta(cars_lm, list())
#'
#' @rdname vetiver_create_meta
#' @export
vetiver_meta <- function(user = list(), version = NULL,
                         url = NULL, required_pkgs = NULL) {
    list(user = user, version = version,
         url = url, required_pkgs = required_pkgs)
}


#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta <- function(model, metadata) {
    UseMethod("vetiver_create_meta")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.default <- function(model, metadata) {
    vetiver_meta(metadata)
}
