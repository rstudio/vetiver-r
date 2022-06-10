#' @keywords internal
"_PACKAGE"


#' @import rlang
#' @importFrom purrr map map_lgl map_chr
#' @importFrom purrr transpose compact pluck
#' @importFrom purrr pmap safely
#' @importFrom utils head modifyList
#' @importFrom vctrs vec_slice vec_sort
#' @importFrom magrittr %>%
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom generics required_pkgs
NULL

#' @importFrom generics augment
#' @export
generics::augment

globalVariables(c("pr", ".metric", ".pred", "price"))

## to avoid NOTE about "All declared Imports should be used."
rapidoc_function_for_note <- function() {
    rapidoc::rapidoc_spec()
}
