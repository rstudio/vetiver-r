#' @rdname vetiver_create_description
#' @export
vetiver_create_description.int_conformal_split <- function(model) {
    spec <- workflows::extract_spec_parsnip(model$wflow)
    glue("A Split Conformal inference with a {spec$engine} {spec$mode} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.int_conformal_split <- function(model, metadata) {
    reqs <- required_pkgs(model)
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.int_conformal_split <- function(model, ...) {
    mold <- workflows::extract_mold(model$wflow)
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.int_conformal_split <- function(model) {
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.int_conformal_split <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.int_conformal_split <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$prototype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}

#' @rdname vetiver_create_description
#' @export
vetiver_create_description.int_conformal_full <- function(model) {
    spec <- workflows::extract_spec_parsnip(model$wflow)
    glue("A full Conformal inference with a {spec$engine} {spec$mode} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.int_conformal_full <- function(model, metadata) {
    reqs <- required_pkgs(model)
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.int_conformal_full <- function(model, ...) {
    mold <- workflows::extract_mold(model$wflow)
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.int_conformal_full <- function(model) {
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.int_conformal_full <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.int_conformal_full <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$prototype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}

#' @rdname vetiver_create_description
#' @export
vetiver_create_description.int_conformal_quantile <- function(model) {
    spec <- workflows::extract_spec_parsnip(model$wflow)
    glue("A quantile Conformal inference with a {spec$engine} {spec$mode} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.int_conformal_quantile <- function(model, metadata) {
    reqs <- required_pkgs(model)
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.int_conformal_quantile <- function(model, ...) {
    mold <- workflows::extract_mold(model$wflow)
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.int_conformal_quantile <- function(model) {
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.int_conformal_quantile <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.int_conformal_quantile <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$prototype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}

#' @rdname vetiver_create_description
#' @export
vetiver_create_description.int_conformal_cv <- function(model) {
    spec <- workflows::extract_spec_parsnip(model$models[[1]])
    n <- length(model$models)
    glue("A {n}-fold CV+ Conformal inference with a {spec$engine} {spec$mode} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.int_conformal_cv <- function(model, metadata) {
    reqs <- required_pkgs(model)
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.int_conformal_cv <- function(model, ...) {
    mold <- workflows::extract_mold(model$models[[1]])
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.int_conformal_cv <- function(model) {
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.int_conformal_cv <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.int_conformal_cv <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$prototype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}
