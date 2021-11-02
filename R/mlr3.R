#' @rdname vetiver_create_description
#' @export
vetiver_create_description.Learner <- function(model) {
    glue("A {model$id} model")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.Learner <- function(model, metadata) {
    reqs <- learner$packages
    reqs <- sort(unique(c(reqs, "mlr3")))
    vetiver_meta(metadata, required_pkgs = reqs)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.Learner <- function(model, ...) {
    as_tibble(model$state$task_prototyp)[, model$state$train_task$feature_names]
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.Learner <- function(model) {
    if (is.null(model$state)) {
        rlang::abort("Your `model` object is not a trained learner.")
    }
    butcher::butcher(model$state$model)
}

#' @rdname handler_startup
#' @export
handler_startup.Learner <- function(vetiver_model) {
    attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handler_startup
#' @export
handler_predict.Learner <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$ptype)
        predict(vetiver_model$model, new_data = new_data, ...)
    }
}