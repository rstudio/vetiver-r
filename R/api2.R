#' Create a route for serving a vetiver model
#'
#' This function creates a routr route with the necessary infrastructure to
#' serve a vetiver model. The route can then be used in any routr based web
#' server such as plumber2 and fiery. For plumber2 specifically there is also
#' [api_vetiver()] which both creates and attaches the route as well as
#' generates OpenAPI documentation for it.
#'
#' @details You can first store and version your [vetiver_model()] with
#' [vetiver_pin_write()], and then create a route with `vetiver_route()`.
#'
#' Several GET endpoints will also be added to the route, depending on the
#' characteristics of the model object:
#'
#' - a `<root>/pin-url` endpoint to return the URL of the pinned model
#' - a `<root>/metadata` endpoint to return any metadata stored with the model
#' - a `<root>/ping` endpoint for the API health
#' - a `<root>/prototype` endpoint for the model's input data prototype (use
#' [cereal::cereal_from_json()]) to convert this back to a
#' [vctrs ptype](https://vctrs.r-lib.org/articles/type-size.html)
#'
#' where `<root>` is everything leading up to the final element of `path` (e.g.
#' if `path = "/model/predict"` then `<root>` would be `/model`)
#'
#' @param model A vetiver model object
#' @param path The path to serve predictions from. Defaults to `/predict`
#' @param ... Additional arguments to pass into `predict()`
#' @param check_prototype Should the input data prototype stored in
#' `vetiver_model` be used to check new data at prediction time? Defaults to
#' `TRUE`.
#'
#' @return A `routr::Route` object that can be used with compatible webserver
#' frameworks
#'
#' @export
#'
#' @examplesIf rlang::is_installed("routr")
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' model_route <- vetiver_route(v, "/cars_linear/predict")
#'
#' # `model_route` can now be attached to a fiery app as a plugin
#'
vetiver_route <- function(
  model,
  path = "/predict",
  ...,
  check_prototype = TRUE
) {
  rlang::check_installed("routr")
  rlang::check_installed("reqres")
  rlang::list2(...) # Forces all dots

  route <- routr::Route$new()
  root <- dirname(path)

  if (!check_prototype) vetiver_model$prototype <- NULL

  route$add_handler(
    "get",
    paste0(root, "/ping"),
    handler = function(request, response, keys, ...) {
      response$status <- 200L
      response$body <- list(status = "online", time = Sys.time())
      response$set_formatter(
        "application/json" = reqres::format_json(
          auto_unbox = TRUE,
          null = "null"
        )
      )
      TRUE
    }
  )
  if (!is.null(model$metadata$url)) {
    route$add_handler(
      "get",
      paste0(root, "/pin-url"),
      handler = function(request, response, keys, ...) {
        response$status <- 200L
        response$body <- model$metadata$url
        response$set_formatter(
          "application/json" = reqres::format_json(
            auto_unbox = TRUE,
            null = "null"
          )
        )
        TRUE
      }
    )
  }
  route$add_handler(
    "get",
    paste0(root, "/metadata"),
    handler = function(request, response, keys, ...) {
      response$status <- 200L
      response$body <- model$metadata
      response$set_formatter(
        "application/json" = reqres::format_json(
          auto_unbox = TRUE,
          null = "null"
        )
      )
      TRUE
    }
  )
  if (!is.null(model$prototype)) {
    prototype <- purrr::map(model$prototype, cereal::cereal_encode)
    route$add_handler(
      "get",
      paste0(root, "/prototype"),
      handler = function(request, response, keys, ...) {
        response$status <- 200L
        response$body <- prototype
        response$set_formatter(
          "application/json" = reqres::format_json(
            auto_unbox = TRUE,
            null = "null"
          )
        )
        TRUE
      }
    )
  }
  handler_startup(model)
  predictor <- handler_predict(model, ...)

  route$add_handler(
    "post",
    path,
    handler = function(request, response, keys, ...) {
      request$parse("application/json" = reqres::parse_json())
      response$status <- 200L
      response$body <- predictor(request)
      response$set_formatter(
        "application/json" = reqres::format_json(
          auto_unbox = TRUE,
          null = "null"
        )
      )
      TRUE
    }
  )
  route
}

#' Serve a vetiver model with plumber2
#'
#' This function creates a [vetiver_route()] and attaches it to a plumber2 api.
#' In addition it will also take care of constructing the relevant OpneAPI spec
#' so that the model is well described.
#'
#' @details You can first store and version your [vetiver_model()] with
#' [vetiver_pin_write()], and then add it to a plumber2 api with
#' `api_vetiver()`.
#'
#' Several GET endpoints in addition to the main POST endpoint will also be
#' added, depending on the characteristics of the model object:
#'
#' - a `<root>/pin-url` endpoint to return the URL of the pinned model
#' - a `<root>/metadata` endpoint to return any metadata stored with the model
#' - a `<root>/ping` endpoint for the API health
#' - a `<root>/prototype` endpoint for the model's input data prototype (use
#' [cereal::cereal_from_json()]) to convert this back to a
#' [vctrs ptype](https://vctrs.r-lib.org/articles/type-size.html)
#'
#' where `<root>` is everything leading up to the final element of `path` (e.g.
#' if `path = "/model/predict"` then `<root>` would be `/model`)
#'
#' # Using annotation
#' vetiver models can also be added to a plumber2 api using the annotation
#' syntax. Currently it is not possible to pass in additional arguments to
#' `predict()`
#'
#' ```
#' #* @vetiver /model/predict
#' vetiver_model(lm(mpg ~ ., data = mtcars), "cars_linear")
#' ```
#'
#' @inheritParams vetiver_route
#' @param theme_docs Should vetiver styling by applied to the OpenAPI
#' documentation. Defaults to `TRUE` but can be turned off if the model serving
#' is incorporated into a larger API. When using the `@vetiver` tag it is set to
#' `FALSE`.
#'
#' @return `api` with the relevant endpoints added
#'
#' @export
#'
#' @examplesIf rlang::is_installed("plumber2")
#'
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#'
#' pa <- plumber2::api() |>
#'   api_vetiver(v, "/cars_linear/predict")
#'
api_vetiver <- function(api,
                        vetiver_model,
                        path = "/predict",
                        ...,
                        check_prototype = TRUE,
                        theme_docs = TRUE) {
  rlang::check_installed("plumber2")

  path <- sub("^/?", "/", path)

  api <- plumber2::api_add_route(
    api,
    "vetiver",
    route = vetiver_route(
      model = vetiver_model,
      path = path,
      ...,
      check_prototype = check_prototype
    )
  )

  if (theme_docs) {
    logo_path <- paste0(dirname(path), "/", "logo.png")
    logo <- paste0(
      '<img slot="logo" src="',
      logo_path,
      '" width=55px style=\"margin-left:7px\"/>'
    )
    logo_file <- system.file("vetiver.png", package = "vetiver")
    api <- plumber2::api_statics(api, logo_path, logo_file)
    api <- plumber2::api_doc_setting(
      api,
      doc_type = "rapidoc",
      slots = logo,
      heading_text = paste("vetiver", utils::packageVersion("vetiver")),
      header_color = "#F2C6AC",
      primary_color = "#8C2D2D"
    )
  }


  api <- plumber2::api_doc_add(
    api,
    doc = create_vetiver_doc(path, vetiver_model, check_prototype)
  )

  api
}

create_vetiver_doc <- function(path, model, add_prototype = TRUE) {
  check_installed("plumber2")
  root <- dirname(path)

  ptype <- model$prototype
  if (is_null(ptype)) {
      request_body <- map_request_body(tibble::tibble(NULL))
      summary <- "Return predictions from model"
  } else {
      request_body <- map_request_body(ptype)
      summary <- glue_spec_summary(ptype)
  }

  metadata_type <- tryCatch(
    list(
      "200" = plumber2::openapi_response(
        description = "",
        content = plumber2::openapi_content(
          "application/json" = plumber2::openapi_schema(model$metadata)
        )
      )
    ),
    error = function(...) list()
  )

  spec <- plumber2::openapi(
    info = plumber2::openapi_info(
      title = glue("{model$model_name} model API"),
      description = model$description,
      version = model$metadata$version %||% "unversioned"
    ),
    paths = list2(
      !!path := plumber2::openapi_path(
        post = plumber2::openapi_operation(
          summary = summary,
          request_body = request_body
        )
      ),
      !!paste0(root, "/ping") := plumber2::openapi_path(
        get = plumber2::openapi_operation(
          "Health check",
          responses = list(
            "200" = plumber2::openapi_response(
              description = "",
              content = plumber2::openapi_content(
                "application/json" = plumber2::openapi_schema(
                  list(status = character(), time = character())
                )
              )
            )
          )
        )
      ),
      !!paste0(root, "/metadata") := plumber2::openapi_path(
        get = plumber2::openapi_operation(
          "Get all metadata of pinned vetiver model",
          responses = metadata_type
        )
      )
    )
  )
  if (!is.null(model$metadata$url)) {
    spec$paths[[paste0(root, "/pin-url")]] <- plumber2::openapi_path(
      get = plumber2::openapi_operation(
        "Get URL of pinned vetiver model",
        responses = list(
          "200" = plumber2::openapi_response(
            description = "",
            content = plumber2::openapi_content(
              "application/json" = plumber2::openapi_schema(character())
            )
          )
        )
      )
    )
  }
  if (add_prototype && !is.null(model$prototype)) {
    spec$paths[[paste0(root, "/prototype")]] <- plumber2::openapi_path(
      get = plumber2::openapi_operation(
        "Get input data prototype for vetiver model",
        responses = list(
          "200" = plumber2::openapi_response(
            description = "",
            content = plumber2::openapi_content(
              "application/json" = plumber2::openapi_schema(list(list(type = character(), example = character(), details = I("object"))))
            )
          )
        )
      )
    )
  }
  spec
}

rlang::on_load(
  rlang::on_package_load("plumber2", {
    plumber2::add_plumber2_tag("vetiver", function(block, call, tags, values, env) {
      if (!inherits(block, "plumber2_empty_block")) {
        cli::cli_abort(
          "{.field @vetiver} cannot be used with other types of annotation blocks"
        )
      }
      path <- trimws(values[[which(tags == "vetiver")[1]]])
      if (is.null(path) || is.na(path) || path == "") path <- "/predict"
      structure(list(
        path = path,
        model = call
      ), class = "plumber2_vetiver_block")
    })
    registerS3method(
      "apply_plumber2_block",
      "plumber2_vetiver_block",
      function(block, api, route_name, root, ...) {
        api_vetiver(api, block$model, path = block$path)
      },
      envir = asNamespace("plumber2")
    )
  })
  )
