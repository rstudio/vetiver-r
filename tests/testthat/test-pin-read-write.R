skip_if_not_installed("mockery")

test_that("can pin a model", {
    b <- board_temp()
    v <- vetiver_model(cars_lm, "cars1")
    expect_snapshot(v)
    vetiver_pin_write(b, v)
    expect_equal(
        pin_read(b, "cars1"),
        list(
            model = butcher::butcher(cars_lm),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:3]), 0)
        )
    )
})

test_that("can pin a model with no prototype", {
    b <- board_temp()
    expect_snapshot_warning(
        v <- vetiver_model(cars_lm, "cars_null", save_ptype = FALSE)
    )
    v <- vetiver_model(cars_lm, "cars_null", save_prototype = FALSE)
    vetiver_pin_write(b, v)
    expect_equal(
        pin_read(b, "cars_null"),
        list(
            model = butcher::butcher(cars_lm),
            prototype = NULL
        )
    )
})

test_that("can pin a model with custom prototype", {
    b <- board_temp()
    v <- vetiver_model(cars_lm, "cars_custom", save_prototype = mtcars[3:10, 2:3])
    vetiver_pin_write(b, v)
    expect_equal(
        pin_read(b, "cars_custom"),
        list(
            model = butcher::butcher(cars_lm),
            prototype = mtcars[3:10, 2:3]
        )
    )
})

test_that("default metadata for model", {
    b <- board_temp()
    v <- vetiver_model(cars_lm, "cars2")
    vetiver_pin_write(b, v)
    meta <- pin_meta(b, "cars2")
    expect_equal(meta$user, list(required_pkgs = NULL, renv_lock = NULL))
    expect_equal(meta$description, "An OLS linear regression model")
})

test_that("user can supply metadata for model", {
    b <- board_temp()
    v <- vetiver_model(cars_lm, "cars3",
                       description = "lm model for mtcars",
                       metadata = list(metrics = 1:10))
    vetiver_pin_write(b, v)
    meta <- pin_meta(b, "cars3")
    expect_equal(meta$user$metrics, 1:10)
    expect_equal(meta$description, "lm model for mtcars")
})

test_that("can read a pinned model", {
    b <- board_temp()
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1")
    vetiver_pin_write(b, v)
    v1 <- vetiver_pin_read(b, "cars1")
    meta <- pin_meta(b, "cars1")
    expect_equal(v1$model, v$model)
    expect_equal(v1$model_name, v$model_name)
    expect_equal(v1$board, v$board)
    expect_equal(v1$description, v$description)
    expect_equal(
        v1$metadata,
        list(user = v$metadata$user,
             version = meta$local$version,
             url = meta$local$url,
             required_pkgs = v$metadata$required_pkgs)
    )
    expect_equal(v1$prototype, v$prototype)
    expect_equal(v1$versioned, FALSE)
})

test_that("can read an old pinned model with `required_pkgs` in blob", {
    b <- board_temp()
    pins::pin_write(
        board = b,
        x = list(
            model = v$model,
            ptype = v$ptype,
            required_pkgs = c("janeaustenr", "beepr")
        ),
        name = "cars-plus-pkgs",
        type = "rds",
        description = v$description,
        metadata = v$metadata$user,
        versioned = v$versioned
    )
    v2 <- vetiver_pin_read(b, "cars-plus-pkgs")
    expect_equal(v2$metadata$required_pkgs, c("janeaustenr", "beepr"))
})

test_that("can read a versioned model with metadata", {
    b <- board_temp(versioned = TRUE)
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars4",
                       description = "lm model for mtcars",
                       metadata = list(metrics = 1:10))
    vetiver_pin_write(b, v)
    v4 <- vetiver_pin_read(b, "cars4")
    meta <- pin_meta(b, "cars4")
    expect_equal(v4$model, v$model)
    expect_equal(v4$model_name, v$model_name)
    expect_equal(v4$board, v$board)
    expect_equal(v4$description, v$description)
    expect_equal(
        v4$metadata,
        list(user = v$metadata$user,
             version = meta$local$version,
             url = meta$local$url,
             required_pkgs = v$metadata$required_pkgs)
    )
    expect_equal(v4$prototype, v$prototype)
    expect_equal(v4$versioned, TRUE)
})

test_that("right message for reading with `check_renv`", {
    skip_on_cran()

    b <- board_temp(versioned = TRUE)
    mock_version_name <- mockery::mock(
        "20130104T050607Z-xxxxx",
        "20130204T050607Z-yyyyy",
        "20130304T050607Z-zzzzz",
    )
    local_mocked_bindings(version_name = mock_version_name, .package = "pins")
    v <- vetiver_model(cars_lm, "cars5")
    v$metadata$required_pkgs <- "ranger"
    vetiver_pin_write(b, v)
    expect_snapshot_warning(vetiver_pin_read(b, "cars5", check_renv = TRUE))

    vetiver_pin_write(b, v, check_renv = TRUE)
    v1 <- vetiver_pin_read(b, "cars5")
    expect_silent(v2 <- vetiver_pin_read(b, "cars5", check_renv = TRUE))
    expect_equal(v1, v2)

    new_lock <- renv$renv_lockfile_init(project = NULL)
    pins::pin_write(
        board = b,
        x = list(
            model = v$model,
            ptype = v$ptype,
            required_pkgs = v$metadata$required_pkgs
        ),
        name = v$model_name,
        type = "rds",
        description = v$description,
        metadata = list_modify(v$metadata$user, renv_lockfile = new_lock),
        versioned = v$versioned
    )

    expect_message(
        vetiver_pin_read(b, "cars5", check_renv = TRUE),
        regexp = "do not match your model"
    )

})
