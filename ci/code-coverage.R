
setTimeLimit(elapsed = 600)

withCallingHandlers(

    expr = covr::codecov(
        quiet = FALSE,
        clean = FALSE,
        install_path = file.path(Sys.getenv("RUNNER_TEMP"), "package")
    ),

    error = function(cnd) {
        print(rlang::trace_back())
        print(vetiver:::renv$renv_debuggify_dump(cnd))
        stop(cnd)
    }

)
