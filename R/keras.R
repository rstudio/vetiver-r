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
    if (length(model$inputs) > 1) {
        abort(c(
            "There is currently no support in vetiver for multi-input keras models.",
            i = "Consider creating a custom handler."
        ))
    }
    rlang::check_dots_used()
    dots <- list(...)
    check_ptype_data(dots)
    ptype <- vctrs::vec_ptype(dots$prototype_data)
    tibble::as_tibble(ptype)
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

    dtype <- vetiver_model$model$input$dtype$name
    shape <- dim(vetiver_model$model$input)

    function(req) {
        new_data <- vetiver_type_convert(req$body, vetiver_model$ptype)
        new_data <- tensorflow::as_tensor(
            as.matrix(new_data),
            dtype = dtype,
            shape = shape
        )
        predict(vetiver_model$model, x = new_data, ...)
    }

}

#' @rdname vetiver_python_requirements
#' @export
vetiver_python_requirements.keras.engine.training.Model <- function(model) {
    ## TODO: something like pip freeze for keras and tensorflow to get versions
    ## Also maybe protobuf because very picky wrt tensorflow
    system.file("requirements/keras-requirements.txt", package = "vetiver")
}
