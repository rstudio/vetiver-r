# nocov start

.onLoad <- function(libname, pkgname) {
    renv$initialize()
    rlang::run_on_load()
}

# nocov end
