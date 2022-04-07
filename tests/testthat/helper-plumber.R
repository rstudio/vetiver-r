library(pins)
library(plumber)
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
v <- vetiver_model(cars_lm, "cars1")

root_path <- "http://localhost"
port <- 6556

local_plumber_session <- function(pr, port, docs = FALSE, env = parent.frame()) {
    rs <- callr::r_session$new()
    rs$call(
        function(pr, port, docs) {
            plumber::pr_run(pr = pr, port = port, docs = docs)
        },
        args = list(pr = pr, port = port, docs = docs)
    )
    withr::defer(rs$close(), envir = env)
    rs
}
