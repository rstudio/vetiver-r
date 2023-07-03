library(pins)

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
v <- vetiver_model(cars_lm, "cars1")

root_path <- "http://localhost"
tmp_dir <- fs::path_real(withr::local_tempdir())
rel_dir <- fs::path_rel(tmp_dir)
port <- ifelse(rlang::is_installed("httpuv"), httpuv::randomPort(), 8088)

redact_vetiver <- function(snapshot) {
    snapshot <- gsub(rel_dir, "<redacted>", snapshot, fixed = TRUE)
    snapshot <- gsub(tmp_dir, "<redacted>", snapshot, fixed = TRUE)
    snapshot <- gsub(getRversion(), "<r_version>", snapshot, fixed = TRUE)
}

redact_port <- function(snapshot) {
    snapshot <- gsub(port, "<port>", snapshot, fixed = TRUE)
}

expect_api_routes <- function(routes) {
    testthat::expect_equal(
        names(routes),
        c("metadata", "ping", "predict", "prototype")
    )
    testthat::expect_equal(
        map_chr(routes, "verbs"),
        c(metadata = "GET", ping = "GET", predict = "POST", prototype = "GET")
    )
}

