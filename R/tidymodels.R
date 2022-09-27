#' @rdname vetiver_create_description
#' @export
vetiver_create_description.workflow <- function(model) {
    spec <- workflows::extract_spec_parsnip(model)
    glue("A {spec$engine} {spec$mode} modeling workflow")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.workflow <- function(model, metadata) {
    reqs <- required_pkgs(model)
    reqs <- sort(unique(c(reqs, "workflows")))
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.workflow <- function(model, ...) {
    mold <- workflows::extract_mold(model)
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.workflow <- function(model) {
    if (!workflows::is_trained_workflow(model)) {
        rlang::abort("Your `model` object is not a trained workflow.")
    }
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.workflow <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.workflow <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$ptype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}
