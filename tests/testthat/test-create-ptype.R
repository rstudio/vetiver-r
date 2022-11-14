b <- board_temp()
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)

test_that("default ptype", {
    expect_equal(
        vetiver_create_ptype(cars_lm, TRUE),
        vctrs::vec_slice(tibble::as_tibble(mtcars[,2:3]), 0)
    )
})

test_that("default ptype, check vetiver_slice_zero", {
    expect_equal(
        vetiver_create_ptype(cars_lm, TRUE),
        vetiver_ptype(cars_lm)
    )
})


test_that("ptype = FALSE", {
    expect_equal(
        vetiver_create_ptype(cars_lm, FALSE),
        NULL
    )
})

test_that("ptype for model with interactions", {
    cars_interaction <- lm(mpg ~ cyl * vs + disp, data = mtcars)
    expect_equal(
        vetiver_create_ptype(cars_interaction, TRUE),
        vctrs::vec_slice(tibble::as_tibble(mtcars[, c(2, 8, 3)]), 0)
    )
})

test_that("custom ptype", {
    expect_equal(
        vetiver_create_ptype(cars_lm, mtcars[3:10, 2:3]),
        mtcars[3:10, 2:3]
    )
})

test_that("bad ptype", {
    expect_snapshot(
        vetiver_create_ptype(cars_lm, "potato"),
        error = TRUE
    )
})
