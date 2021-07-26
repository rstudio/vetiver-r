#' Identify data types for each column in an input data prototype
#'
#' The OpenAPI specification of a Plumber API created via [plumber::pr()] can
#' be modified via [plumber::pr_set_api_spec()], and this helper function will
#' identify data types of predictors and create a list to use in this
#' specification. These are *not* R data types, but instead basic JSON data
#' types. For example, factors in R will be documented as strings in the
#' OpenAPI specification.
#'
#' @param ptype An input data prototype from a model
#'
#' @return A list to be used within [plumber::pr_set_api_spec()]
#' @export
#'
#' @examples
#' map_request_body(vctrs::vec_slice(chickwts, 0))
#'
map_request_body <- function(ptype) {
    ptype_prop <- map_ptype(ptype)
    list(content = list(
        `application/json` = list(
            schema = list(
                type = "array",
                minItems = 1,
                items = list(
                    type = "object",
                    properties = ptype_prop
                )
            )
        )
    ))
}

map_ptype <- function(ptype) {
    ret <- as.list(ptype)
    ## use `plumber:::plumberToApiTypeMap` here instead?
    ret <- purrr::map(
        ret,
        ~ switch(class(.),
                 numeric = "number",
                 integer = "integer",
                 logical = "boolean",
                 "string"
        )
    )
    purrr::map(ret, ~ list(type = .))
}
