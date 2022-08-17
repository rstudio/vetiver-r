#' @rdname vetiver_create_description
#' @export
vetiver_create_description.gam <- function(model) {
    glue("A generalized additive model ({model$family$family} family, {model$family$link} link)")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.gam <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.gam <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "mgcv")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.gam <- function(model, ...) {
    vetiver_ptype.lm(model, ...)
}

#' @rdname handler_startup
#' @export
handler_startup.gam <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.gam <- function(vetiver_model, ...) {
    handler_predict.lm(vetiver_model, ...)
}
