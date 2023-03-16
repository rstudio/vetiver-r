#' @rdname vetiver_create_description
#' @export
vetiver_create_description.luz_module_fitted <- function(model) {
    n_parameters <- lapply(model$model$parameters, function(x) prod(x$shape))
    n_parameters <- do.call(sum, n_parameters)
    n_parameters <- formatC(n_parameters, big.mark = ",", format = "d")
    glue("A luz module with {n_parameters} parameters")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.luz_module_fitted <- function(model, metadata) {
    pkgs <- c("luz", model$model$required_pkgs)
    vetiver_meta(metadata, required_pkgs = pkgs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.luz_module_fitted <- function(model, ...) {
    rlang::check_dots_used()
    dots <- list(...)
    check_ptype_data(dots)
    ptype <- vctrs::vec_ptype(dots$prototype_data)
    tibble::as_tibble(ptype)
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.luz_module_fitted <- function(model) {
    bundle::bundle(model)
}

#' @rdname handler_startup
#' @export
handler_startup.luz_module_fitted <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.luz_module_fitted <- function(vetiver_model, ...) {
    force(vetiver_model)
    function(req) {
        new_data <- vetiver_type_convert(req$body, vetiver_model$ptype)
        preds <- tensors_to_array(predict(vetiver_model$model, as.array(as.matrix(new_data))))
        preds
    }
}

tensors_to_array <- function(x) {
    if (is.list(x)) {
        lapply(x, tensors_to_array)
    } else if (inherits(x, "torch_tensor")) {
        as.array(x$cpu())
    } else {
        x
    }
}
