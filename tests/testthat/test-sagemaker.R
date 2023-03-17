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


test_that("can create SageMaker Model", {
    mockery::stub(vetiver_sm_model, "smdocker::smdocker_config", list())
    mockery::stub(vetiver_sm_model, "sagemaker_client$create_model", list())
    image_uri <- "999999999999.dkr.ecr.us-east-2.amazonaws.com/vetiver-sagemaker-example-model:2023-03-17"
    model_name <- "vetiver-sagemaker-example_model"
    role <- "arn:aws:iam::999999999999:role/SagemakerExecution"

    expect_snapshot(error = TRUE, {
        vetiver_sm_model(image_uri = image_uri, role = role, tags = "potato")
        vetiver_sm_model(image_uri = image_uri, role = role, tags = list("potato"))
    })

    out <-
        vetiver_sm_model(
            image_uri = image_uri,
            model_name = model_name,
            role = role,
            tags = list("new-tag" = "amazing")
        )

    expect_equal(out, model_name)
})

