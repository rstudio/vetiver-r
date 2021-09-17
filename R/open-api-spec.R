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

    if (nrow(ptype) > 0) {
        schema_list <- list(
            type = "array",
            minItems = 1,
            items = list(
                type = "object",
                properties = ptype_prop
            ),
            example = purrr::transpose(ptype)
        )
    } else {
        schema_list <- list(
            type = "array",
            minItems = 1,
            items = list(
                type = "object",
                properties = ptype_prop
            )
        )
    }

    list(content = list(`application/json` = list(schema = schema_list)))
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

#' Update the OpenAPI specification from model metadata
#'
#' @param spec An OpenAPI Specification formatted list object
#' @inheritParams modelops_pr_predict
#'
#' @return The new OpenAPI Specification object updated
#' @export
#'
api_spec <- function(spec, modelops, path) {
    ptype <- modelops$ptype
    spec$info$title <- glue::glue("{modelops$model_name} model API")
    spec$info$description <- modelops$desc

    request_body <- map_request_body(ptype)
    orig_post <- spec[["paths"]][[path]][["post"]]
    spec$paths[[path]]$post <- list(
        summary = glue::glue("Return predictions from model using {dim(ptype)[[2]]} features"),
        requestBody = request_body,
        responses = orig_post$responses
    )

    if ("/pin-url" %in% names(spec$paths)) {
        spec$paths$`/pin-url`$get$summary <- "Get URL of pinned modelops object"
    }

    spec
}

