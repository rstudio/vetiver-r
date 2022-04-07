library(plumber)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars1")
pr <- pr() %>% vetiver_api(v)
root_path <- "http://localhost"
port <- 8000

local_plumber_session <- function(pr, port, docs = FALSE) {
    rs <- callr::r_session$new()
    rs$call(
        function(pr, port, docs) {
            plumber::pr_run(pr = pr, port = port, docs = docs)
        },
        args = list(pr = pr, port = port, docs = docs)
    )
    rs
}
rs <- local_plumber_session(pr, port)
withr::defer(rs$close())

test_that("router has health check endpoint", {
    r <- httr::GET(root_path, port = port, path = "ping")
    expect_equal(r$status_code, 200)
})

test_that("can predict on basic vetiver router", {
    endpoint <- vetiver_endpoint(paste0(root_path, ":", port, "/predict"))
    preds <- predict(endpoint, mtcars[10:17, -1])
    expect_s3_class(preds, "tbl_df")
    expect_equal(nrow(preds), 8)
})
