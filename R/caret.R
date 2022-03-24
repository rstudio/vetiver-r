#' @rdname vetiver_create_description
#' @export
vetiver_create_description.train <- function(model) {
    glue("A {tolower(model$modelInfo$label)} {tolower(model$modelType)} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.train <- function(model, metadata) {
    reqs <- c("caret", model$modelInfo$library)
    reqs <- sort(unique(reqs))
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.train <- function(model, ...) {
    tibble::as_tibble(model$ptype)
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.train <- function(model) {
    butcher::butcher(model)
}

#' @rdname handler_startup
#' @export
handler_startup.train <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.train <- function(vetiver_model, ...) {

    function(req) {
        newdata <- req$body
        newdata <- vetiver_type_convert(newdata, vetiver_model$ptype)
        predict(vetiver_model$model, newdata = newdata, ...)
    }

}
