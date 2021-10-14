library(pins)

test_that("create plumber.R with packages", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1", b)
    v$metadata$required_pkgs <- c("beepr", "janeaustenr")
    vetiver_pin_write(v)
    vetiver_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})

test_that("create plumber.R with args in dots", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1", b)
    v$metadata$required_pkgs <- c("beepr", "janeaustenr")
    vetiver_pin_write(v)
    vetiver_write_plumber(b, "cars1", endpoint = "/predict2", type = "numeric", file = tmp)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})

test_that("create plumber.R with no packages", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1", b)
    vetiver_pin_write(v)
    vetiver_write_plumber(b, "cars1", file = tmp, docs = NULL)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})

test_that("If docs package isn't found, an error is thrown (or tried to be installed)", {
    skip_on_cran()
    rlang::local_interactive(FALSE)

    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1", b)
    vetiver_pin_write(v)
    expect_error(
      vetiver_write_plumber(b, "cars1", file = tmp, docs = "unknown-package"),
      "unknown-package"
    )
})
