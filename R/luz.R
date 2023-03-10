#' @rdname vetiver_create_description
#' @export
vetiver_create_description.luz_module_fitted <- function(model) {
    glue("A luz module")
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

    data <- dots$prototype_data
    data <- tensors_to_array(data)

    # luz doesn't require named inputs. we use `input` if the user didn't provide any.
    if (!is.list(data)) {
        data <- tibble::tibble(input = data)
    }

    ptype <- vctrs::vec_ptype(data)
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
        preds <- asNamespace("vetiver")$tensors_to_array(predict(vetiver_model$model, new_data))
        tibble::tibble(.pred = preds)
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
