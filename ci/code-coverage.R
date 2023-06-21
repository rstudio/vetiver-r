
vetiver:::renv$the$log_level <- 1L

command <- paste("sleep 600 && kill -INT", Sys.getpid())
system(command, wait = FALSE)

command <- paste("sleep 660 && kill -TERM", Sys.getpid())
system(command, wait = FALSE)

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
