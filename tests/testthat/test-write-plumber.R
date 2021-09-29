library(pins)
library(plumber)

test_that("create plumber.R", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    m <- modelops(cars_lm, "cars1", b)
    m$metadata$required_pkgs <- c("beepr", "janeaustenr")
    modelops_pin_write(m)
    modelops_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(readr::read_lines(tmp))
})
