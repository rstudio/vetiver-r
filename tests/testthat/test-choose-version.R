skip_if_not_installed("mockery")

test_that("can choose a version", {
    skip_on_cran()
    b <- board_temp(versioned = TRUE)
    mock_version_name <- mockery::mock(
        "20130104T050607Z-xxxxx",
        "20130204T050607Z-yyyyy",
        "20130304T050607Z-zzzzz",
    )
    local_mocked_bindings(version_name = mock_version_name, .package = "pins")
    mod1 <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(mod1, "cars1")
    vetiver_pin_write(b, v)
    mod2 <- lm(mpg ~ cyl + drat, data = mtcars)
    v <- vetiver_model(mod2, "cars1")
    vetiver_pin_write(b, v)
    mod3 <- lm(mpg ~ cyl + wt, data = mtcars)
    v <- vetiver_model(mod3, "cars1")
    vetiver_pin_write(b, v)
    p <- pins::pin_versions(b, "cars1")
    expect_equal(p$version[[3]], choose_version(p))
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

