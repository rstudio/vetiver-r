library(pins)

b <- board_temp()

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)

test_that("can pin a model", {
    pin_model(b, cars_lm, "cars1")
    expect_equal(
        pin_read(b, "cars1"),
        list(
            model = butcher::butcher(cars_lm),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:3]), 0)
        )
    )
})

test_that("can pin a model with no ptype", {
    pin_model(b, cars_lm, "cars1", ptype = FALSE)
    expect_equal(
        pin_read(b, "cars1"),
        list(
            model = butcher::butcher(cars_lm),
            ptype = NULL
        )
    )
})

test_that("default metadata for model", {
    pin_model(b, cars_lm, "cars2")
    meta <- pin_meta(b, "cars2")
    expect_equal(meta$user, NULL)
    expect_equal(meta$description, "An OLS linear regression model")
})

test_that("user can supply metadata for model", {
    pin_model(b, cars_lm, "cars3",
              desc = "lm model for mtacrs",
              metadata = list(metrics = 1:10))
    meta <- pin_meta(b, "cars3")
    expect_equal(meta$user, list(metrics = 1:10))
    expect_equal(meta$description, "lm model for mtacrs")
})
