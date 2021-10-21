#' Fully attach or load packages for making model predictions
#'
#' These are developer-facing functions, useful for supporting new model types.
#' Some models require one or more R packages to be fully attached to make
#' predictions, and some require only that the namespace of one or more R
#' packages is loaded.
#'
#' @details These two functions will attempt either to:
#'
#' - fully attach or
#' - load
#'
#' the namespace of the `pkgs` vector of package names, preserving the current
#' random seed.
#'
#' To learn more about load vs. attach, read the [NAMESPACE chapter of
#' *R Packages*](https://r-pkgs.org/namespace.html). For deploying a model, it
#' is likely safer to fully attach needed packages but that comes with the risk
#' of naming conflicts between packages.
#'
#' @param pkgs A character vector of package names to load or fully attach.
#'
#' @return An invisible `TRUE`.
#' @family namespace
#' @export
#'
#' @examples
#' ## succeed
#' load_pkgs(c("knitr", "readr"))
#' attach_pkgs(c("knitr", "readr"))
#'
#' ## fail
#' try(load_pkgs(c("bloopy", "readr")))
#' try(attach_pkgs(c("bloopy", "readr")))
#'
attach_pkgs <- function(pkgs) {
    namespace_handling(pkgs, attachNamespace, "Package(s) could not be attached:")
}

#' @export
#' @rdname attach_pkgs
load_pkgs <- function(pkgs) {
    namespace_handling(pkgs, loadNamespace, "Namespace(s) could not be loaded:")
}

namespace_handling <- function(pkgs, func, error_msg) {
    loaded <- map_lgl(pkgs, isNamespaceLoaded)
    pkgs <- pkgs[!loaded]

    safe_load <- safely(withr::with_preserve_seed(func))

    did_load <- map(pkgs, safe_load)
    bad <- compact(map(did_load, "error"))
    bad <- map_chr(bad, "package")
    if (length(bad) >= 1) {
        abort(c(error_msg, bad))
    }

    invisible(TRUE)
}
