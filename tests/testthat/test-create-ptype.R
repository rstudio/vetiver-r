library(pins)

b <- board_temp()
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)

test_that("default ptype", {
    expect_equal(
        modelops_create_ptype(cars_lm, TRUE),
        vctrs::vec_slice(tibble::as_tibble(mtcars[,2:3]), 0)
    )
})

test_that("default ptype, check modelops_slice_zero", {
    expect_equal(
        modelops_create_ptype(cars_lm, TRUE),
        modelops_slice_zero(cars_lm)
    )
})


test_that("ptype = FALSE", {
    expect_equal(
        modelops_create_ptype(cars_lm, FALSE),
        NULL
    )
})

test_that("custom ptype", {
    expect_equal(
        modelops_create_ptype(cars_lm, mtcars[3:10, 2:3]),
        mtcars[3:10, 2:3]
    )
})
