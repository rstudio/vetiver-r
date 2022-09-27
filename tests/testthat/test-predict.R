skip_on_cran()
skip_if_not_installed(c("pingr", "httr"))

pr <- pr() %>% vetiver_api(v, debug = TRUE)
rs <- local_plumber_session(pr, port)

## on GH actions, it can take A WHILE for the API to come up on some architectures:
for (i in 1:100) {
    if (pingr::is_up(root_path, port)) break
    Sys.sleep(0.1)
}

test_that("router has health check endpoint", {
    r <- httr::GET(root_path, port = port, path = "ping")
    expect_equal(r$status_code, 200)
})

test_that("can predict on basic vetiver router", {
    endpoint <- vetiver_endpoint(paste0(root_path, ":", port, "/predict"))
    expect_s3_class(endpoint, "vetiver_endpoint")
    expect_snapshot(print(endpoint), transform = redact_port)

    preds <- predict(endpoint, mtcars[10:17, 2:3])
    expect_s3_class(preds, "tbl_df")
    expect_equal(nrow(preds), 8)
    expect_equal(ncol(preds), 1)

    aug <- augment(endpoint, mtcars[10:17, 2:3])
    expect_s3_class(aug, "tbl_df")
    expect_equal(nrow(aug), 8)
    expect_equal(ncol(aug), 3)
})

test_that("get correct errors", {
    endpoint <- vetiver_endpoint(paste0(root_path, ":", port, "/predict"))
    expect_snapshot(predict(endpoint, mtcars[, 2:4]), error = TRUE)
    expect_snapshot(predict(endpoint, mtcars[, 3:5]), error = TRUE)
})

