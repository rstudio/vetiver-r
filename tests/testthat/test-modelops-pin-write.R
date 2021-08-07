library(pins)

b <- board_temp()

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)

test_that("can pin a model", {
    m <- modelops(cars_lm, "cars1", b)
    modelops_pin_write(m)
    expect_equal(
        pin_read(b, "cars1"),
        list(
            model = butcher::butcher(cars_lm),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:3]), 0)
        )
    )
})

test_that("can pin a model with no ptype", {
    m <- modelops(cars_lm, "cars_null", b, ptype = FALSE)
    modelops_pin_write(m)
    expect_equal(
        pin_read(b, "cars_null"),
        list(
            model = butcher::butcher(cars_lm),
            ptype = NULL
        )
    )
})

test_that("default metadata for model", {
    m <- modelops(cars_lm, "cars2", b)
    modelops_pin_write(m)
    meta <- pin_meta(b, "cars2")
    expect_equal(meta$user, NULL)
    expect_equal(meta$description, "An OLS linear regression model")
})

test_that("user can supply metadata for model", {
    m <- modelops(cars_lm, "cars3", b,
                  desc = "lm model for mtcars",
                  metadata = list(metrics = 1:10))
    modelops_pin_write(m)
    meta <- pin_meta(b, "cars3")
    expect_equal(meta$user, list(metrics = 1:10))
    expect_equal(meta$description, "lm model for mtcars")
})
