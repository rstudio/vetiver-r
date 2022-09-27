#' @rdname vetiver_create_description
#' @export
vetiver_create_description.model_stack <- function(model) {
    num_members <-
        tidy(model$coefs) %>%
        dplyr::filter(estimate > 0, term != "(Intercept)") %>%
        nrow()
    glue("A {model$mode} stacked ensemble with {num_members} members")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.model_stack <- function(model, metadata) {
    reqs <- map(model$member_fits, required_pkgs)
    reqs <- purrr::flatten_chr(reqs)
    reqs <- sort(unique(c(reqs, required_pkgs(model$coefs), "workflows", "stacks")))
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.model_stack <- function(model, ...) {
    mold <- workflows::extract_mold(model$member_fits[[1]])
    mold$blueprint$ptypes$predictors
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.model_stack <- function(model) {
    ret <- butcher::butcher(model)
    ret <- bundle::bundle(ret)
    ret
}

#' @rdname handler_startup
#' @export
handler_startup.model_stack <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.model_stack <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$ptype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}
