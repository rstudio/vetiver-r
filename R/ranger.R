#' @rdname vetiver_create_description
#' @export
vetiver_create_description.ranger <- function(model) {
    glue("A ranger {tolower(model$forest$treetype)} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.ranger <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "ranger")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.ranger <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.ranger <- function(model, ...) {
    rlang::check_dots_used()
    dots <- list(...)
    check_ptype_data(dots)
    ptype <- vctrs::vec_ptype(dots$ptype_data)
    tibble::as_tibble(ptype)
}

#' @rdname handler_startup
#' @export
handler_startup.ranger <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.ranger <- function(vetiver_model, ...) {

    ptype <- vetiver_model$ptype

    function(req) {
        new_data <- req$body
        if (!is_null(ptype)) {
            new_data <- vetiver_type_convert(new_data, ptype)
            new_data <- hardhat::scream(new_data, ptype)
        }
        ret <- predict(vetiver_model$model, data = new_data, ...)
        list(.pred = ret$predictions)
    }
}
