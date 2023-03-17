#' @keywords internal
"_PACKAGE"


#' @import rlang
#' @importFrom purrr map map_lgl map_chr
#' @importFrom purrr transpose compact pluck
#' @importFrom purrr pmap safely list_modify
#' @importFrom utils head modifyList flush.console
#' @importFrom stats predict
#' @importFrom vctrs vec_slice vec_sort
#' @importFrom magrittr %>%
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom generics required_pkgs
#' @importFrom lifecycle deprecated
NULL

#' @importFrom generics augment
#' @export
generics::augment

#' @importFrom generics required_pkgs
#' @export
generics::required_pkgs

globalVariables(c("pr", ".metric", ".pred", "price", "tidy",
                  "term", "estimate", "terms"))

## to avoid NOTE about "All declared Imports should be used."
rapidoc_function_for_note <- function() {
    rapidoc::rapidoc_spec()
}

release_bullets <- function() {
    c(
        'Update renv with `renv:::vendor()`'
    )
}

