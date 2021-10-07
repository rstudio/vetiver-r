
test_that("all numeric", {
    expect_equal(
        vetiver_type_convert(mtcars, vctrs::vec_slice(mtcars, 0)),
        mtcars
    )
})

test_that("a factor", {
    chicks <- chickwts
    chicks$feed <- as.character(chicks$feed)

    expect_equal(
        vetiver_type_convert(chicks, vctrs::vec_slice(chickwts, 0)),
        chickwts
    )
})

test_that("a factor plus a bad character", {
    teeth <- ToothGrowth
    teeth$supp <- as.character(teeth$supp)
    teeth$dose <- as.character(teeth$dose)

    expect_equal(
        vetiver_type_convert(teeth, vctrs::vec_slice(ToothGrowth, 0)),
        ToothGrowth
    )
})

test_that("a date", {

    many_dates <- tibble::tibble(
        x = as.Date("2021-01-01") + 0:10,
        y = as.Date("1980-02-14") + 0:10,
        z = as.POSIXct("1950-06-01", tz = "UTC") + 0:10
    )

    new_data <- tibble::tibble(
        x = "2021-01-15", y = "1980-03-01", z = "1950-06-01 00:00:15"
    )

    expect_equal(
        vetiver_type_convert(new_data, vctrs::vec_slice(many_dates, 0)),
        tibble::tibble(
            x = as.Date("2021-01-15"),
            y = as.Date("1980-03-01"),
            z = as.POSIXct("1950-06-01 00:00:15", tz = "UTC")
        )
    )
})


