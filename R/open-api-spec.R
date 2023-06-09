#' Identify data types for each column in an input data prototype
#'
#' The OpenAPI specification of a Plumber API created via [plumber::pr()] can
#' be modified via [plumber::pr_set_api_spec()], and this helper function will
#' identify data types of predictors and create a list to use in this
#' specification. These are *not* R data types, but instead basic JSON data
#' types. For example, factors in R will be documented as strings in the
#' OpenAPI specification.
#'
#' @param prototype An input data prototype from a model
#'
#' @return A list to be used within [plumber::pr_set_api_spec()]
#'
#' @details
#' This is a developer-facing function, useful for supporting new model types.
#' It is called by [api_spec()].
#'
#' @examples
#' map_request_body(vctrs::vec_slice(chickwts, 0))
#'
#' @export
map_request_body <- function(prototype) {
    UseMethod("map_request_body")
}

#' @export
map_request_body.default <- function(prototype) {
    abort("There is no method available to create visual documentation for `prototype`.")
}

#' @export
map_request_body.data.frame <- function(prototype) {
    ptype_prop <- map_ptype(prototype)

    if (nrow(prototype) > 0) {
        schema_list <- list(
            type = "array",
            minItems = 1,
            items = list(
                type = "object",
                properties = ptype_prop
            ),
            example = purrr::pmap(prototype, list)
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
    ret <- map(
        ret,
        ~ switch(class(.)[[1]],
                 numeric = "number",
                 integer = "integer",
                 logical = "boolean",
                 "string"
        )
    )
    map(ret, ~ list(type = .))
}


#' @export
map_request_body.array <- function(prototype) {

    dims <- dim(prototype)
    ptype_prop <- map(dims, ~ list(type = "array",
                                   minItems = .x,
                                   maxItems = .x,
                                   type = "number"))
    ptype_prop <- set_names(ptype_prop, glue("dim{seq_along(dims)}"))

    if (dims[1] > 0) {
        schema_list <- list(
            type = "array",
            minItems = 1,
            items = list(
                type = "object",
                properties = ptype_prop
            ),
            example = prototype
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


#' Update the OpenAPI specification using model metadata
#'
#' @param spec An OpenAPI Specification formatted list object
#' @inheritParams vetiver_api
#' @inheritParams map_request_body
#' @param return_type Character string to describe what endpoint returns, such
#' as "predictions"
#'
#' @return `api_spec()` returns the updated OpenAPI Specification object. This
#' function uses `glue_spec_summary()` internally, which returns a `glue`
#' character string.
#' @export
#'
#' @examplesIf rlang::is_installed("plumber")
#' library(plumber)
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#'
#' glue_spec_summary(v$prototype)
#'
#' modify_spec <- function(spec) api_spec(spec, v, "/predict")
#' pr() %>% pr_set_api_spec(api = modify_spec)
#'
api_spec <- function(spec, vetiver_model, path, all_docs = TRUE) {
    spec$info$title <- glue("{vetiver_model$model_name} model API")
    spec$info$description <- vetiver_model$description
    spec$info$version <- vetiver_model$metadata$version
    if ("/pin-url" %in% names(spec$paths)) {
        spec$paths$`/pin-url`$get$summary <- "Get URL of pinned vetiver model"
    }
    if ("/metadata" %in% names(spec$paths)) {
        spec$paths$`/metadata`$get$summary <- "Get all metadata of pinned vetiver model"
    }
    if ("/prototype" %in% names(spec$paths)) {
        spec$paths$`/prototype`$get$summary <- "Get input data prototype for vetiver model"
    }
    if ("/ping" %in% names(spec$paths)) {
        spec$paths$`/ping`$get$summary <- "Health check"
    }


    ptype <- vetiver_model$prototype
    if (is_null(ptype)) {
        request_body <- map_request_body(tibble::tibble(NULL))
        summary <- "Return predictions from model"
    } else {
        request_body <- map_request_body(ptype)
        summary <- glue_spec_summary(ptype)
    }

    if (all_docs) {
        endpoints <- map_chr(spec$paths, names)
        endpoints <- names(endpoints[endpoints == "post"])
        endpoints <- setdiff(endpoints, path)

        spec <- update_spec(spec, path, summary, request_body)

        for (endpoint in endpoints) {
            endpoint_summary <- glue_spec_summary(ptype, endpoint)
            spec <- update_spec(spec, endpoint, endpoint_summary, request_body)
        }
    }

    if (has_connect_redirect(spec)) {
        spec$paths$`/` <- NULL
    }

    spec
}

update_spec <- function(spec, endpoint, summary, request_body) {
    orig_post <- pluck(spec, "paths", endpoint, "post")
    spec$paths[[endpoint]]$post <- list(
        summary = summary,
        requestBody = request_body,
        responses = orig_post$responses
    )
    spec
}

has_connect_redirect <- function(spec) {
    endpoint <- spec$paths$`/`
    summary <- endpoint$get$summary
    connect_summary <-
        grepl("^This endpoint was added to automatically redirect visitors", summary)

    if (is.null(endpoint) || is.null(summary) || !connect_summary) {
        return(FALSE)
    } else {
        return(TRUE)
    }
}

#' @rdname api_spec
#' @export
glue_spec_summary <- function(prototype, return_type) {
    UseMethod("glue_spec_summary")
}

#' @rdname api_spec
#' @export
glue_spec_summary.default <- function(prototype, return_type = NULL) {
    abort("There is no method available to create a spec summary for `ptype`.")
}

#' @rdname api_spec
#' @export
glue_spec_summary.data.frame <- function(prototype, return_type = "predictions") {
    cli::pluralize("Return {return_type} from model using {ncol(prototype)} feature{?s}")
}

#' @rdname api_spec
#' @export
glue_spec_summary.array <- function(prototype, return_type = "predictions") {
    "Return {return_type} from model using multidimensional array"
}


