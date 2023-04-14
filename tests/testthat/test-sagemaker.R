skip_if_not_installed("smdocker")

test_that("can deploy via `vetiver_deploy_sagemaker()`", {
    skip_on_cran()
    model_name <- "example_model_name"
    instance_type <- "ml.t2.medium"
    mockery::stub(vetiver_deploy_sagemaker, "vetiver_sm_build", "new_sagemaker_uri")
    mockery::stub(vetiver_deploy_sagemaker, "vetiver_sm_model", model_name)
    mockery::stub(vetiver_deploy_sagemaker, "vetiver_sm_endpoint", vetiver_endpoint_sagemaker(model_name))
    local_mocked_bindings(version_name = function(metadata) "20130102T050607Z-xxxxx", .package = "pins")

    b <- board_folder(path = tmp_dir)
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1")
    vetiver_pin_write(b, v)

    expect_snapshot(vetiver_deploy_sagemaker(b, "cars1", instance_type), error = TRUE)

    class(b) <- c("pins_board_s3", "pins_board")
    out <- vetiver_deploy_sagemaker(b, "cars1", instance_type)
    expect_equal(out, vetiver_endpoint_sagemaker(model_name))
})

test_that("can create correct files for `vetiver_sm_build()`", {
    skip_on_cran()
    mockery::stub(vetiver_sm_build, "smdocker::sm_build", "new_sagemaker_uri")
    local_mocked_bindings(version_name = function(metadata) "20130202T050607Z-xxxxx", .package = "pins")

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
    mockery::stub(vetiver_sm_model, "sagemaker_client$create_model", list())
    image_uri <- "999999999999.dkr.ecr.us-east-2.amazonaws.com/vetiver-sagemaker-example-model:2023-03-17"
    model_name <- "vetiver-sagemaker-example_model"
    role <- "arn:aws:iam::999999999999:role/SagemakerExecution"

    expect_snapshot(error = TRUE, {
        vetiver_sm_model(image_uri = image_uri, role = role, tags = "potato")
        vetiver_sm_model(image_uri = image_uri, role = role, tags = list("potato"))
        vetiver_sm_model(image_uri = image_uri, role = role,
                         vpc_config = list("potato"))
        vetiver_sm_model(image_uri = image_uri, role = role,
                         vpc_config = list(Subnets = list(1:3), SecurityGroupIds = 1:3))
        vetiver_sm_model(image_uri = image_uri, role = role,
                         vpc_config = list(Subnets = 1:3, SecurityGroupIds = list(1:3)))
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

test_that("can create SageMaker Endpoint", {
    mockery::stub(vetiver_sm_endpoint, "sagemaker_client$create_endpoint_config", list())
    mockery::stub(vetiver_sm_endpoint, "sm_create_endpoint", "example-endpoint-name")
    model_name <- "vetiver-sagemaker-example_model"
    instance_type <- "ml.t2.medium"

    expect_snapshot(error = TRUE, {
        vetiver_sm_endpoint(model_name = model_name, instance_type = instance_type, tags = "potato")
        vetiver_sm_endpoint(model_name = model_name, instance_type = instance_type, tags = list("potato"))
    })

    out <-
        vetiver_sm_endpoint(
            model_name = model_name,
            instance_type = instance_type,
            tags = list("new-tag" = "amazing")
        )

    expect_equal(out, vetiver_endpoint_sagemaker(model_name))
})

test_that("can call sm_create_endpoint", {
    mockery::stub(sm_create_endpoint, "client$create_endpoint", list())

    endpoint_name <- "vetiver-sagemaker-example-model"
    config_name <- "vetiver-sagemaker-config"
    client <- paws.machine.learning::sagemaker(list())

    expect_snapshot(
        out <- sm_create_endpoint(client, endpoint_name, config_name, wait = FALSE)
    )

    expect_equal(out, endpoint_name)
})

test_that("can delete SageMaker endpoints", {
    mock_delete_endpoint_config <- mockery::mock(abort("No config!"), list())
    mock_delete_model <- mockery::mock(list(), cycle = TRUE)
    mockery::stub(vetiver_sm_delete, "sagemaker_client$describe_endpoint", list(EndpointConfigName = "the-name"))
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint_config", mock_delete_endpoint_config)
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint", list())
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_model", mock_delete_model)

    object <- vetiver_endpoint_sagemaker("vetiver-sagemaker-example-model")

    expect_snapshot(vetiver_sm_delete(object))
    expect_true(vetiver_sm_delete(object))
    # Check if delete model and endpoint have been called
    mockery::expect_called(mock_delete_endpoint_config, 2)
    mockery::expect_called(mock_delete_model, 2)
})

test_that("can delete SageMaker model but not endpoint", {
    mock_delete_endpoint_config <- mockery::mock(list(EndpointConfigName = "dummy-endpoint"))
    mock_delete_model <- mockery::mock(list())
    mockery::stub(vetiver_sm_delete, "sagemaker_client$describe_endpoint", list(EndpointConfigName = "the-name"))
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint_config", mock_delete_endpoint_config)
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint", list())
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_model", mock_delete_model)

    object <- vetiver_endpoint_sagemaker("vetiver-sagemaker-example-model")

    expect_true(vetiver_sm_delete(object, delete_endpoint = FALSE))
    # Check if delete model and endpoint have been called
    mockery::expect_called(mock_delete_endpoint_config, 0)
    mockery::expect_called(mock_delete_model, 1)
})

test_that("can delete SageMaker endpoints but not model", {
    mock_delete_endpoint_config <- mockery::mock(list(EndpointConfigName = "dummy-endpoint"))
    mock_delete_model <- mockery::mock(list())
    mockery::stub(vetiver_sm_delete, "sagemaker_client$describe_endpoint", list(EndpointConfigName = "the-name"))
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint_config", mock_delete_endpoint_config)
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_endpoint", list())
    mockery::stub(vetiver_sm_delete, "sagemaker_client$delete_model", mock_delete_model)

    object <- vetiver_endpoint_sagemaker("vetiver-sagemaker-example-model")

    expect_true(vetiver_sm_delete(object, delete_model = FALSE))
    # Check if delete model and endpoint have been called
    mockery::expect_called(mock_delete_endpoint_config, 1)
    mockery::expect_called(mock_delete_model, 0)
})

test_that("can create vetiver endpoint object", {
    mockery::stub(
        vetiver_endpoint_sagemaker,
        "smdocker::smdocker_config",
        list(region = "my-region")
    )

    model_endpoint <- "vetiver-sagemaker-example-model"

    expect_snapshot(
        vetiver_endpoint_sagemaker(list()),
        error = TRUE
    )
    expect_snapshot(vetiver_endpoint_sagemaker(model_endpoint))
})

test_that("can predict with vetiver endpoint object", {

    res <- tibble::tibble(.pred = mtcars$mpg)
    mockery::stub(
        vetiver_endpoint_sagemaker,
        "smdocker::smdocker_config",
        list(region = "my-region")
    )
    mockery::stub(
        predict.vetiver_endpoint_sagemaker,
        "sm_runtime$invoke_endpoint",
        list(Body = charToRaw(jsonlite::toJSON(res)))
    )
    mockery::stub(augment.vetiver_endpoint_sagemaker, "predict", res)

    endpoint <- vetiver_endpoint_sagemaker("example-model")
    expect_equal(predict(endpoint, mtcars), res)
    expect_equal(augment(endpoint, mtcars), vctrs::vec_cbind(tibble::tibble(mtcars), res))

})

test_that("can get base name from image", {
    image_uri <- "999999999999.dkr.ecr.us-east-2.amazonaws.com/vetiver-sagemaker-example-model:2023-03-17"

    expect_true(grepl(
        "vetiver-sagemaker-example-model-[0-9]{4,}-[0-9]{2,}-[0-9]{2,}-[0-9]{2,}-[0-9]{2,}-[0-9]{2,}-[0-9]{3,}",
        base_name_from_image(image_uri)
    ))
})
