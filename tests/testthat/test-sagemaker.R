skip_if_not_installed("smdocker")
skip_on_cran()

test_that("can create correct files for `vetiver_sm_build()`", {
    mockery::stub(vetiver_sm_build, "smdocker::sm_build", "new_sagemaker_uri")

    b <- board_folder(path = tmp_dir)
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1")
    vetiver_pin_write(b, v)

    new_uri <- vetiver_sm_build(b, "cars1", path = tmp_dir)
    expect_equal(new_uri, "new_sagemaker_uri")

    expect_true(fs::file_exists(fs::path(tmp_dir, "vetiver_renv.lock")))
    expect_snapshot(
        cat(readr::read_lines(fs::path(tmp_dir, "plumber.R")), sep = "\n"),
        transform = redact_vetiver
    )
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})
