# nocov start

renv <- rlang::env()

load_renv_env <- function() {
    script <- system.file("resources/renv.R", package = "vetiver")
    sys.source(script, envir = renv)
}

.onLoad <- function(libname, pkgname) {
    load_renv_env()
    renv$renv_platform_init()
    renv$renv_envvars_init()
    renv$renv_log_init()
    renv$renv_methods_init()
    renv$renv_filebacked_init()
    renv$renv_libpaths_init()
    renv$renv_patch_init()
}

# nocov end
