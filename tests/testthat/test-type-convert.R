test_that("all numeric", {
    expect_equal(
        vetiver_type_convert(mtcars, vctrs::vec_slice(mtcars, 0)),
        tibble::tibble(mtcars)
    )
})

test_that("NULL ptype, for save_ptype = FALSE", {
    expect_equal(
        vetiver_type_convert(chickwts, NULL),
        chickwts
    )
})

test_that("missing variables", {
    expect_snapshot_error(
        vetiver_type_convert(mtcars[,2:3], vctrs::vec_slice(mtcars, 0)),
    )
}) ## extra variables are caught by hardhat::scream()

test_that("a factor", {
    chicks <- chickwts
    chicks$feed <- as.character(chicks$feed)

    expect_equal(
        vetiver_type_convert(chicks, vctrs::vec_slice(chickwts, 0)),
        tibble::tibble(chickwts)
    )
})

test_that("a factor plus a bad character", {
    teeth <- ToothGrowth
    teeth$supp <- as.character(teeth$supp)
    teeth$dose <- as.character(teeth$dose)

    expect_equal(
        vetiver_type_convert(teeth, vctrs::vec_slice(ToothGrowth, 0)),
        tibble::tibble(ToothGrowth)
    )

    expect_snapshot_error(
        vetiver_type_convert(tibble::tibble(len = 4.2, supp = "ZZ", dose = 0.1),
                             vctrs::vec_slice(ToothGrowth, 0))
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

    bad_data <- tibble::tibble(
        x = "potato", y = "1980-03-01", z = "1950-06-01 00:00:15"
    )

    expect_equal(
        vetiver_type_convert(new_data, vctrs::vec_slice(many_dates, 0)),
        tibble::tibble(
            x = as.Date("2021-01-15"),
            y = as.Date("1980-03-01"),
            z = as.POSIXct("1950-06-01 00:00:15", tz = "UTC")
        )
    )

    expect_snapshot_error(
        vetiver_type_convert(bad_data, vctrs::vec_slice(many_dates, 0)),
    )
})
