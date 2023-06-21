
Sys.setenv(RENV_LOG_LEVEL = "debug")

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
        stop(cnd)
    },

    interrupt = function(cnd) {
        print(rlang::trace_back())
        stop(cnd)
    }

)
