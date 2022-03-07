library(pins)

b <- board_folder(path = tmp_dir)
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
v <- vetiver_model(cars_lm, "cars1")

test_that("create Dockerfile with packages", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("beepr", "caret")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with no packages", {
    skip_on_cran()
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})
