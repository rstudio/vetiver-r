#' Deploy a vetiver model API to Amazon SageMaker
#'
#' @description Use `vetiver_deploy_sagemaker()` to deploy a [vetiver_model()]
#' that has been versioned and stored via [vetiver_pin_write()] as a Plumber API
#' on Amazon SageMaker.
#'
#' @inheritParams vetiver_sm_build
#' @inheritParams vetiver_sm_model
#' @inheritParams vetiver_sm_endpoint
#' @param ... Not currently used.
#' @param build_args A list of optional arguments passed to
#' [vetiver_sm_build()] such as the model `version` or the `compute_type`.
#' @param endpoint_args A list of optional arguments passed to
#' [vetiver_sm_endpoint()] such as `accelerator_type` or `data_capture_config`.
#' @param repo_name The name for the AWS ECR repository to store the model.
#'
#' @details
#' This function stores your model deployment image in the same bucket used
#' by `board`.
#'
#' The function `vetiver_deploy_sagemaker()` uses:
#' - [vetiver_sm_build()] to build and push a Docker image to ECR,
#' - [vetiver_sm_model()] to create a SageMaker model, and
#' - [vetiver_sm_endpoint()] to deploy a SageMaker model endpoint.
#'
#' These modular functions are available for more advanced use cases.
#'
#' @return
#' The deployed [vetiver_endpoint_sagemaker()].
#'
#' @seealso [vetiver_sm_build()], [vetiver_sm_model()], [vetiver_sm_endpoint()]
#' @export
#' @examples
#' if (FALSE) {
#' library(pins)
#' b <- board_s3(bucket = "my-existing-bucket")
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' endpoint <- vetiver_deploy_sagemaker(
#'     board = b,
#'     name = "cars_linear",
#'     instance_type = "ml.t2.medium",
#'     predict_args = list(type = "class", debug = TRUE)
#' )
#' }
#'
vetiver_deploy_sagemaker <- function(board,
                                     name,
                                     instance_type,
                                     ...,
                                     predict_args = list(),
                                     docker_args = list(),
                                     build_args = list(),
                                     endpoint_args = list(),
                                     repo_name = glue("vetiver-sagemaker-{name}")) {

    ellipsis::check_dots_empty()
    if (!inherits(board, "pins_board_s3")) {
        stop_input_type(board, "an S3 pins board")
    }

    repo_name <- ifelse(
        grepl(":", repo_name),
        repo_name,
        glue("{repo_name}:{strftime(Sys.time(), '%Y-%m-%d')}")
    )

    # build image and push to aws ecr
    build_args <- compact(c(
        list(board = board,
             name = name,
             predict_args = predict_args,
             docker_args = docker_args,
             repository = repo_name,
             bucket = board$bucket),
        build_args
    ))
    image_uri <- do.call(vetiver_sm_build, build_args)

    tags <- sm_check_tags(endpoint_args$tags)
    tags <- list_modify(
        tags,
        "vetiver:pin_board" = glue("s3://{board$bucket}/{board$prefix %||% ''}"),
        "vetiver:r-ver" = getRversion()
    )
    endpoint_args$tags <- NULL

    # create sagemaker model
    model_name <- vetiver_sm_model(image_uri, tags = tags)

    # create sagemaker endpoint
    endpoint_args <- compact(c(
        list(
            model_name = model_name,
            instance_type = instance_type,
            tags = tags),
        endpoint_args
    ))
    endpoint <- do.call(vetiver_sm_endpoint, endpoint_args)
    return(endpoint)
}

#' Deploy a vetiver model API to Amazon SageMaker with modular functions
#'
#' @description
#' Use the function [vetiver_deploy_sagemaker()] for basic deployment on
#' SageMaker, or these three functions together for more advanced use cases:
#' - `vetiver_sm_build()` generates and builds a Docker image on SageMaker for
#' a vetiver model
#' - `vetiver_sm_model()` creates an Amazon SageMaker model
#' - `vetiver_sm_endpoint()` deploys an Amazon SageMaker model endpoint
#'
#' @inheritParams vetiver_prepare_docker
#' @param repository The ECR repository and tag for the image as a character.
#' Defaults to `sagemaker-studio-${domain_id}:latest`.
#' @param compute_type The [CodeBuild](https://aws.amazon.com/codebuild/)
#' compute type as a character. Defaults to `BUILD_GENERAL1_SMALL`.
#' @param role The IAM role name for CodeBuild to use as a character. Defaults
#' to the SageMaker Studio execution role.
#' @param bucket The S3 bucket to use for sending data to CodeBuild as a
#' character. Defaults to the SageMaker SDK default bucket.
#' @param vpc_id ID of the VPC that will host the CodeBuild project such as
#' `"vpc-05c09f91d48831c8c"`.
#' @param subnet_ids List of subnet IDs for the CodeBuild project, such as
#' `list("subnet-0b31f1863e9d31a67")`.
#' @param security_group_ids List of security group IDs for the CodeBuild
#' project, such as `list("sg-0ce4ec0d0414d2ddc")`.
#' @param log A logical to show the logs of the running CodeBuild build.
#' Defaults to `TRUE`.
#' @param ... [Docker build parameters](https://docs.docker.com/engine/reference/commandline/build/#options>)
#' (Use "_" instead of "-"; for example, Docker optional parameter
#' `build-arg` becomes `build_arg`).
#'
#' @details The function `vetiver_sm_build()` generates the files necessary to
#' build a Docker container to deploy a vetiver model in SageMaker and then
#' builds the image on [AWS CodeBuild](https://aws.amazon.com/codebuild/). The
#' resulting image is stored in [AWS ECR](https://aws.amazon.com/ecr/).
#' This function creates a Plumber file and Dockerfile appropriate for
#' SageMaker, for example, with `path = "/invocations"` and `port = 8080`.
#'
#' If you run into problems with Docker rate limits, then either
#' - authenticate to Docker from SageMaker, or
#' - use a [public ECR base image](https://gallery.ecr.aws/docker/library/r-base),
#' passed through `docker_args`
#'
#' @seealso [vetiver_prepare_docker()], [vetiver_deploy_sagemaker()], [vetiver_endpoint_sagemaker()]
#' @examples
#' if (FALSE) {
#' library(pins)
#' b <- board_s3(bucket = "my-existing-bucket")
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' new_image_uri <- vetiver_sm_build(
#'     board = b,
#'     name = "cars_linear",
#'     predict_args = list(type = "class", debug = TRUE),
#'     docker_args = list(
#'         base_image = "FROM public.ecr.aws/docker/library/r-base:4.2.2"
#'     )
#' )
#'
#' model_name <- vetiver_sm_model(
#'     new_image_uri,
#'     tags = list("my_custom_tag" = "fuel_efficiency")
#' )
#'
#' vetiver_sm_endpoint(model_name, "ml.t2.medium")
#' }
#' @return `vetiver_sm_build()` returns the AWS ECR image URI and
#' `vetiver_sm_model()` returns the model name (both as characters).
#' `vetiver_sm_endpoint()` returns a new [vetiver_endpoint_sagemaker()] object.
#' @export
vetiver_sm_build <- function(board,
                             name,
                             version = NULL,
                             path = fs::dir_create(tempdir(), "vetiver"),
                             predict_args = list(),
                             docker_args = list(),
                             repository = NULL,
                             compute_type = c(
                                 "BUILD_GENERAL1_SMALL",
                                 "BUILD_GENERAL1_MEDIUM",
                                 "BUILD_GENERAL1_LARGE",
                                 "BUILD_GENERAL1_2XLARGE"
                             ),
                             role = NULL,
                             bucket = NULL,
                             vpc_id = NULL,
                             subnet_ids = list(),
                             security_group_ids = list(),
                             log = TRUE,
                             ...) {
    check_installed("smdocker")
    ellipsis::check_dots_used()
    compute_type <- arg_match(compute_type)
    docker_args <- list_modify(docker_args, port = 8080)
    predict_args <- list_modify(predict_args, path = "/invocations")

    vetiver_prepare_docker(
        board = board,
        name = name,
        version = version,
        path = path,
        predict_args = predict_args,
        docker_args = docker_args
    )

    image_uri <- smdocker::sm_build(
        repository = repository,
        compute_type = compute_type,
        role = role,
        dir = path,
        bucket = bucket,
        vpc_id = vpc_id,
        subnet_ids = subnet_ids,
        security_group_ids = security_group_ids,
        log = log,
        ...
    )

    return(image_uri)
}

#' @param image_uri The AWS ECR image URI for the Amazon SageMaker Model to be
#' created (for example, as returned by [vetiver_sm_build()]).
#' @param model_name The Amazon SageMaker model name to be deployed.
#' @param role The ARN role for the Amazon SageMaker model. Defaults to the
#' SageMaker execution role.
#' @param vpc_config A list containing the VPC configuration for the Amazon
#' SageMaker model [API VpcConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_VpcConfig.html)
#' (optional).
#' * `Subnets`: List of subnet ids
#' * `SecurityGroupIds`: List of security group ids
#' @param enable_network_isolation A logical to specify whether the container
#' will run in network isolation mode. Defaults to `FALSE`.
#' @param tags A named list of tags for labeling the Amazon SageMaker model or
#' model endpint to be created.
#' @rdname vetiver_sm_build
#' @export
vetiver_sm_model <- function(image_uri,
                             model_name,
                             role = NULL,
                             vpc_config = list(),
                             enable_network_isolation = FALSE,
                             tags = list()) {
    check_installed(c("smdocker", "paws.machine.learning"))
    config <- smdocker::smdocker_config()
    sagemaker_client <- paws.machine.learning::sagemaker(config)

    if (is_missing(model_name)) {
        model_name <- base_name_from_image(image_uri)
    }

    if (is.null(role)) {
        role <- smdocker::sagemaker_get_execution_role()
    }
    tags <- sm_check_tags(tags)
    tags <- sm_format_tags(tags)

    request <- list(
        "ModelName" = model_name,
        "ExecutionRoleArn" = role,
        "PrimaryContainer" = list("Image" = image_uri)
    )
    request$Tags <- .sm_append_project_tags(tags)
    request$VpcConfig <- sm_check_vpc_config(vpc_config)
    if (isTRUE(enable_network_isolation)) {
        request$EnableNetworkIsolation <- TRUE
    }
    # create model
    do.call(sagemaker_client$create_model, request)

    return(model_name)
}

#' @param instance_type Type of EC2 instance to use; see
#' [Amazon SageMaker pricing](https://aws.amazon.com/sagemaker/pricing/).
#' @param endpoint_name The name to use for the Amazon SageMaker model endpoint
#' to be created, if to be different from `model_name`.
#' @param initial_instance_count The initial number of instances to run
#' in the endpoint.
#' @param accelerator_type Type of Elastic Inference accelerator to
#' attach to an endpoint for model loading and inference, for
#' example, `"ml.eia1.medium"`.
#' @param kms_key The ARN of the KMS key used to encrypt the data on the
#' storage volume attached to the instance hosting the endpoint.
#' @param data_capture_config A list for configuration to control how Amazon
#' SageMaker captures inference data.
#' @param volume_size The size, in GB, of the ML storage volume attached to
#' the individual inference instance associated with the production variant.
#' Currently only Amazon EBS gp2 storage volumes are supported.
#' @param model_data_download_timeout The timeout value, in seconds, to download
#' and extract model data from Amazon S3.
#' @param wait A logical for whether to wait for the endpoint to be deployed.
#' Defaults to `TRUE`.
#' @rdname vetiver_sm_build
#' @export
vetiver_sm_endpoint <- function(model_name,
                                instance_type,
                                endpoint_name = NULL,
                                initial_instance_count = 1,
                                accelerator_type = NULL,
                                tags = list(),
                                kms_key = NULL,
                                data_capture_config = list(),
                                volume_size = NULL,
                                model_data_download_timeout = NULL,
                                wait = TRUE) {
    check_installed(c("smdocker", "paws.machine.learning"))

    config <- smdocker::smdocker_config()
    sagemaker_client <- paws.machine.learning::sagemaker(config)

    endpoint_name <- endpoint_name %||% model_name

    tags <- sm_check_tags(tags)
    tags <- sm_format_tags(tags)

    request <- sm_req_endpoint_config(
        model_name,
        endpoint_name,
        instance_type,
        initial_instance_count,
        accelerator_type,
        volume_size,
        model_data_download_timeout,
        .sm_append_project_tags(tags),
        kms_key,
        data_capture_config
    )

    # create endpoint config
    resp <- do.call(
        sagemaker_client$create_endpoint_config,
        request
    )

    # create endpoint
    endpoint_name <- sm_create_endpoint(
        sagemaker_client, model_name, endpoint_name, tags, wait
    )

    return(vetiver_endpoint_sagemaker(model_name))
}

#' Delete Amazon SageMaker model, endpoint, and endpoint configuration
#'
#' Use this function to delete the Amazon SageMaker components used in a
#' [vetiver_endpoint_sagemaker()] object. This function does _not_ delete
#' any pinned model object in S3.
#'
#' @param object The model API endpoint object to be deleted, created with
#' [vetiver_endpoint_sagemaker()].
#' @param delete_model Delete the SageMaker model? Defaults to `TRUE`.
#' @param delete_endpoint Delete both the endpoint and endpoint configuration?
#' Defaults to `TRUE`.
#' @return `TRUE`, invisibly
#' @seealso [vetiver_deploy_sagemaker()], [vetiver_sm_build()], [vetiver_endpoint_sagemaker()]
#' @export
vetiver_sm_delete <- function(object, delete_model = TRUE, delete_endpoint = TRUE) {
    check_installed(c("smdocker", "paws.machine.learning"))

    config <- smdocker::smdocker_config()
    sagemaker_client <- paws.machine.learning::sagemaker(config)

    endpoint_name <- object$model_endpoint

    if (is_true(delete_endpoint)) {
        tryCatch(
            {
                endpoint_describe <- sagemaker_client$describe_endpoint(
                    EndpointName = endpoint_name
                )
                endpoint_config_name <- endpoint_describe$EndpointConfigName
                sagemaker_client$delete_endpoint_config(endpoint_config_name)
            },
            error = function(err) {
                cli::cli_warn("Unable to delete {.val {endpoint_name}} endpoint configuration.")
            }
        )
        sagemaker_client$delete_endpoint(endpoint_name)
    }
    if (is_true(delete_model)) {
        sagemaker_client$delete_model(endpoint_name)
    }
    return(invisible(TRUE))
}

#' Post new data to a deployed SageMaker model endpoint and return predictions
#'
#' @param object A SageMaker model endpoint object created with [vetiver_endpoint_sagemaker()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [paws.machine.learning::sagemakerruntime_invoke_endpoint()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @seealso [augment.vetiver_endpoint_sagemaker()]
#' @export
#' @examples
#' if (FALSE) {
#'   endpoint <- vetiver_endpoint_sagemaker("sagemaker-demo-model")
#'   predict(endpoint, mtcars[4:7, -1])
#' }
#' @export
predict.vetiver_endpoint_sagemaker <- function(object, new_data, ...) {
    check_installed(c("jsonlite", "smdocker", "paws.machine.learning"))
    data_json <- jsonlite::toJSON(new_data, na = "string")
    config <- smdocker::smdocker_config()
    sm_runtime <- paws.machine.learning::sagemakerruntime(config)
    tryCatch(
        {
            resp <- sm_runtime$invoke_endpoint(object$model_endpoint, data_json, ...)
            resp <- resp$Body
        },
        error = function(error) {
            error_code <- error$error_response$ErrorCode
            if (!is.null(error_code) && error_code == "NO_SUCH_ENDPOINT") {
                cli::cli_abort("Model endpoint {.val {object$model_endpoint}} not found.")
            }
            stop(error)
        }
    )
    con <- rawConnection(resp)
    on.exit(close(con))
    resp <- jsonlite::fromJSON(con)
    return(tibble::as_tibble(resp))
}

#' Post new data to a deployed SageMaker model endpoint and augment with predictions
#'
#' @param x A SageMaker model endpoint object created with [vetiver_endpoint_sagemaker()].
#' @inheritParams predict.vetiver_endpoint_sagemaker
#'
#' @return The `new_data` with added prediction column(s).
#' @seealso [predict.vetiver_endpoint_sagemaker()]
#' @export
#' @examples
#'
#' if (FALSE) {
#'   endpoint <- vetiver_endpoint_sagemaker("sagemaker-demo-model")
#'   augment(endpoint, mtcars[4:7, -1])
#' }
#'
augment.vetiver_endpoint_sagemaker <- function(x, new_data, ...) {
    preds <- predict(x, new_data = new_data, ...)
    vctrs::vec_cbind(tibble::as_tibble(new_data), preds)
}


#' Create a SageMaker model API endpoint object for prediction
#'
#' This function creates a model API endpoint for prediction from a Sagemaker Model.
#' No HTTP calls are made until you actually
#' [`predict()`][predict.vetiver_endpoint_sagemaker()] with your endpoint.
#'
#' @param model_endpoint The name of the Amazon SageMaker model endpoint.
#' @return A new `vetiver_endpoint_sagemaker` object
#'
#' @examplesIf rlang::is_installed("smdocker")
#' vetiver_endpoint_sagemaker("vetiver-sagemaker-demo-model")
#' @export
vetiver_endpoint_sagemaker <- function(model_endpoint) {
    check_installed("smdocker")
    config <- smdocker::smdocker_config()
    check_character(model_endpoint)
    check_character(config$region)
    new_vetiver_endpoint_sagemaker(model_endpoint, config$region)
}

new_vetiver_endpoint_sagemaker <- function(model_endpoint = character(),
                                           region = character()) {
    structure(
        list(model_endpoint = model_endpoint, region = region),
        class = "vetiver_endpoint_sagemaker"
    )
}

#' @export
format.vetiver_endpoint_sagemaker <- function(x, ...) {
    cli::cli_format_method({
        cli::cli_h3("A SageMaker model endpoint for prediction:")
        cli::cli_text("Model endpoint: {x$model_endpoint}")
        cli::cli_text("Region: {x$region}")
    })
}

#' @export
print.vetiver_endpoint_sagemaker <- function(x, ...) {
    cat(format(x), sep = "\n")
    invisible(x)
}
