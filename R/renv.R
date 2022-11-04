renv <- rlang::env()

load_renv_env <- function() {
    script <- system.file("resources/renv.R", package = "vetiver")
    sys.source(script, envir = renv)
}
