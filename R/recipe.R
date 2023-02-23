#' @rdname vetiver_create_description
#' @export
vetiver_create_description.recipe <- function(model) {
    num_steps <- length(model$steps)
    cli::pluralize("A feature engineering recipe with {num_steps} step{?s}")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.recipe <- function(model, metadata) {
    reqs <- required_pkgs(model)
    reqs <- sort(unique(c(reqs, "recipes")))
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.recipe <- function(model, ...) {
    rlang::check_dots_used()
    dots <- list(...)
    check_ptype_data(dots)
    ptype <- vctrs::vec_ptype(dots$prototype_data)
    tibble::as_tibble(ptype)
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.recipe <- function(model) {
    if (!recipes::fully_trained(model)) {
        rlang::abort("Your `model` object is not a trained recipe.")
    }
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.recipe <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.recipe <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <- vetiver_type_convert(new_data, vetiver_model$prototype)
        recipes::bake(vetiver_model$model, new_data = new_data, ...)
    }
}
