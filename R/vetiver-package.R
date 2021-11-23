#' @keywords internal
"_PACKAGE"


#' @import purrr
#' @importFrom utils head
#' @importFrom rlang abort warn
#' @importFrom rlang expr expr_deparse
#' @importFrom rlang is_null
#' @importFrom rlang is_interactive
#' @importFrom rlang has_name
#' @importFrom vctrs vec_slice
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom generics required_pkgs
NULL

#' @importFrom generics augment
#' @export
generics::augment

globalVariables(c("pr"))
