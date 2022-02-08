#' @rdname vetiver_create_description
#' @export
vetiver_create_description.glm <- function(model) {
    glue("A generalized linear model ({model$family$family} family, {model$family$link} link)")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.glm <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.glm <- function(model, ...) {
    vetiver_ptype.lm(model, ...)
}

#' @rdname handler_startup
#' @export
handler_predict.glm <- function(vetiver_model, ...) {
    handler_predict.lm(vetiver_model, ...)
}
