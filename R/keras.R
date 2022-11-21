#' @rdname vetiver_create_description
#' @export
vetiver_create_description.keras.engine.training.Model <- function(model) {
    model_config <- model$get_config()
    glue("A {model_config$name} keras model with {length(model_config$layers)} layers")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.keras.engine.training.Model <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "keras")
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.keras.engine.training.Model <- function(model, ...) {
    NULL
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.keras.engine.training.Model <- function(model) {
    bundle::bundle(model)
}

#' @rdname handler_startup
#' @export
handler_startup.keras.engine.training.Model <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.keras.engine.training.Model <- function(vetiver_model, ...) {

    function(req) {
        new_data <- as.matrix(req$body)
        #new_data <- vetiver_type_convert(new_data, vetiver_model$ptype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }

}
