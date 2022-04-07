skip_on_cran()

test_that("router has health check endpoint", {
    pr <- pr() %>% vetiver_api(v)
    rs <- local_plumber_session(pr, port)
    Sys.sleep(1)
    r <- httr::GET(root_path, port = port, path = "ping")
    expect_equal(r$status_code, 200)
})

test_that("can predict on basic vetiver router", {
    pr <- pr() %>% vetiver_api(v)
    rs <- local_plumber_session(pr, port)
    Sys.sleep(1)
    endpoint <- vetiver_endpoint(paste0(root_path, ":", port, "/predict"))
    preds <- predict(endpoint, mtcars[10:17, 2:3])
    expect_s3_class(preds, "tbl_df")
    expect_equal(nrow(preds), 8)
})
