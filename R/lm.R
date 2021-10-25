#' @rdname vetiver_create_description
#' @export
vetiver_create_description.lm <- function(model) {
    "An OLS linear regression model"
}

#' @rdname vetiver_create_description
#' @export
vetiver_prepare_model.lm <- function(model) {
    butcher::butcher(model)
}

#' @rdname vetiver_create_ptype
#' @export
vetiver_ptype.lm <- function(model, ...) {
    pred_names <- attr(model$terms, "term.labels")
    ptype <- vctrs::vec_ptype(model$model[pred_names])
    tibble::as_tibble(ptype)
}

#' @rdname handler_startup
#' @export
handler_predict.lm <- function(vetiver_model, ...) {

    ptype <- vetiver_model$ptype

    function(req) {
        newdata <- req$body
        if (!is_null(ptype)) {
            newdata <- vetiver_type_convert(newdata, ptype)
            newdata <- hardhat::scream(newdata, ptype)
        }
        ret <- predict(vetiver_model$model, newdata = newdata, ...)
        list(.pred = ret)
    }

}
