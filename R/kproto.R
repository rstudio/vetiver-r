#' @rdname vetiver_create_description
#' @export
vetiver_create_description.kproto <- function(model) {
    glue("A k-prototypes clustering model ({length(model$size)} clusters)")
}

#' @rdname vetiver_create_meta
#' @export
vetiver_create_meta.kproto <- function(model, metadata) {
    vetiver_meta(metadata, required_pkgs = "clustMixType")
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.kproto <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.kproto <- function(model, ...) {
    prototype <- vctrs::vec_ptype(model$data)
    tibble::as_tibble(prototype)
}

#' @rdname handler_startup
#' @export
handler_predict.kproto <- function(vetiver_model, ...) {

    prototype <- vetiver_model$prototype

    function(req) {
        newdata <- req$body
        if (!is_null(prototype)) {
            newdata <- vetiver_type_convert(newdata, prototype)
            newdata <- hardhat::scream(newdata, prototype)
        }
        newdata <- as.data.frame(newdata)
        # clustMixType:::predict.kproto()
        ret <- predict(vetiver_model$model, newdata = newdata, ...)
        list(.pred = ret$cluster)
    }
}
