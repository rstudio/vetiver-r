test_that("can choose a version", {
    b <- board_temp()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1")
    vetiver_pin_write(b, v)
    Sys.sleep(0.5)
    vetiver_pin_write(b, v)
    Sys.sleep(0.5)
    vetiver_pin_write(b, v)
    p <- pins::pin_versions(b, "cars1")
    expect_equal(p$version[[1]], choose_version(p))
})

test_that("can choose a version by `active` column like on Connect", {
    p <- tibble::tibble(version = 4500:4509,
                        created = NA,
                        active = c(TRUE, rep(FALSE, 9)),
                        size = rpois(10, 2000))
    expect_equal(choose_version(p), 4500)
})

test_that("can warn for strange setups", {
    p <- tibble::tibble(version = 4500:4509,
                        size = rpois(10, 2000))
    expect_snapshot(p <- choose_version(p))
    expect_equal(p, 4500)
})

