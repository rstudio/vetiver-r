options(pins.verbose = FALSE)
options(pins.quiet = TRUE)
options(renv.verbose = FALSE)
Sys.setenv(RENV_CONFIG_SNAPSHOT_VALIDATE = FALSE)

clean_python_tmp_dir <- function() {
    if (!rlang::is_installed("reticulate"))
        return()

    if(!reticulate::py_available())
        return()

    tryCatch(
        error = function(cnd) {
            cli::cli_inform("Cannot clean Python temp directory: {cnd}")
        },
        {
            python_temp_dir <- dirname(reticulate::py_run_string(
                "import tempfile; x=tempfile.NamedTemporaryFile().name",
                local = TRUE
            )$x)
            detritus <- fs::dir_ls(
                python_temp_dir,
                regexp = "__autograph_generated_file|__pycache__"
            )
            fs::file_delete(detritus)
        }
    )
}

withr::defer(clean_python_tmp_dir(), teardown_env())
