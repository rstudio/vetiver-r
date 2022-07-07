#' @rdname vetiver_create_description
#' @export
vetiver_create_description.tabnet_fit <- function(model) {
    cli::cat_line(
        "A tabnet  `nn_module` containing ",
        comma(get_parameter_count(model$fit$network)),
        " parameters."
  )
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.tabnet_fit <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "tabnet")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.tabnet_fit <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.tabnet_fit <- function(model, ...) {
    rlang::check_dots_used()
    dots <- list(...)
    check_ptype_data(dots)
    ptype <- vctrs::vec_ptype(dots$ptype_data)
    tibble::as_tibble(ptype)
}

#' @rdname handler_startup
#' @export
handler_startup.tabnet_fit <- function(vetiver_model) {
    attach_pkgs("tabnet")
}

#' @rdname handler_startup
#' @export
handler_predict.tabnet_fit <- function(vetiver_model, ...) {

    ptype <- vetiver_model$blueprint$ptypes

    function(req) {
        new_data <- req$body
        if (!is_null(ptype)) {
            new_data <- vetiver_type_convert(new_data, ptype)
            new_data <- hardhat::scream(new_data, ptype)
        }
        ret <- predict(vetiver_model, data = new_data, ...)
        list(.pred = ret$.pred)
    }
}
