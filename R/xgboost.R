#' @rdname vetiver_create_description
#' @export
vetiver_create_description.xgb.Booster <- function(model) {
    if (!is_null(model$params$objective)) {
        ret <- glue("An xgboost {model$params$objective} model")
    } else {
        "An xgboost model"
    }
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.xgb.Booster <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "xgboost")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.xgb.Booster <- function(model, ...) {
    pred_names <- matrix(NA_real_,
                         ncol = model$nfeatures,
                         dimnames = list("", model$feature_names))
    ptype <- vctrs::vec_ptype(pred_names)
    tibble::as_tibble(ptype)
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.xgb.Booster <- function(model) {
    bundle::bundle(model)
}

#' @rdname handler_startup
#' @export
handler_startup.xgb.Booster <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.xgb.Booster <- function(vetiver_model, ...) {

    ptype <- vetiver_model$prototype

    function(req) {
        newdata <- req$body
        if (!is_null(ptype)) {
            newdata <- vetiver_type_convert(newdata, ptype)
            newdata <- hardhat::scream(newdata, ptype)
        }
        newdata <- xgboost::xgb.DMatrix(as.matrix(newdata))
        ret <- predict(vetiver_model$model, newdata = newdata, ...)
        list(.pred = ret)
    }
}
