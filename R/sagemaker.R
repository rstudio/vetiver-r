#' @import rlang
#' @importFrom glue glue
#' @importFrom stats predict

#' @include sagemaker_utils.R

#' @title Deploy a vetiver model API to RStudio Connect
#'
#' @description Use `vetiver_deploy_sagemaker()` to deploy a [vetiver_model()] that has been
#' versioned and stored via [vetiver_pin_write()] as a Plumber API on
#' `Amazon SageMaker`.
#'
#' @inheritParams vetiver_write_plumber
#' @param predict_args A list of optional arguments passed to [vetiver_api()]
#' such as the endpoint `path` or prediction `type`.
#' @param repo_name The `AWS ECR` repository name to store the model.
#' @param compute_type The `AWS CodeBuild` instance to build docker for the model.
#' @param instance_type The `Amazon SageMaker` instance to host the model.
#' @param ... Other arguments passed to [vetiver_sm_endpoint()] such as
#' `accelerator_type` or `data_capture_config`.
#'
#' @details The two functions `vetiver_deploy_rsconnect()` and
#' [vetiver_create_rsconnect_bundle()] are alternatives to each other, providing
#' different strategies for deploying a vetiver model API to RStudio Connect.
#'
#' @return
#' The deployment success (`TRUE` or `FALSE`), invisibly.
#'
#' @seealso [vetiver_write_plumber()], [vetiver_create_rsconnect_bundle()]
#' @export
vetiver_deploy_sagemaker <- function(board,
                                     name,
                                     version = NULL,
                                     predict_args = list(),
                                     repo_name = glue("vetiver-sagemaker-{name}"),
                                     compute_type = c(
                                       "BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM",
                                       "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"
                                     ),
                                     instance_type = NULL,
                                     ...) {
  # create dockerfile using
  # https://github.com/rocker-org/rocker-versioned2/pkgs/container/r-ver
  tmp <- fs::dir_create(tempdir(), "vetiver")
  withr::local_dir(tmp)
  vetiver_write_plumber(
    board = board,
    name = name,
    version = version,
    !!!predict_args
  )
  v <- vetiver_pin_read(board = board, name = name, version = version)
  vetiver_write_docker(
    v,
    port = 8080,
    base_image = glue("FROM ghcr.io/rocker-org/r-ver:{getRversion()}"),
    additional_pkgs = required_pkgs(board)
  )

  repo_name <- ifelse(
    grepl(":", repo_name),
    repo_name,
    glue("{repo_name}:{strftime(Sys.time(), '%Y-%m-%d')}")
  )

  # build image and push to aws ecr
  image_uri <- vetiver_sm_build(
    repository = repo_name,
    compute_type = compute_type,
    dir = tmp,
    bucket = board$bucket
  )

  args <- list2(...)
  tags <- args$tags
  args$tags <- NULL

  # create sagemaker model
  model_name <- vetiver_sm_model(image_uri, tags = tags)

  # create sagemaker endpoint
  endpoint_args <- c(
    model_name = model_name, instance_type = instance_type, args
  )
  endpoint <- do.call(vetiver_sm_endpoint, endpoint_args)
  return(endpoint)
}

#' @title Use `AWS CodeBuild` to build docker images and push them to Amazon `ECR`
#' @description This function takes a directory containing a
#' [dockerfile](https://docs.docker.com/engine/reference/builder/), and builds it on
#' [`AWS CodeBuild`](https://aws.amazon.com/codebuild/). The resulting image is
#' then stored in [`AWS ECR`](https://aws.amazon.com/ecr/) for later use.
#' @param repository (character): The `ECR` repository:tag for the image
#' (default: `sagemaker-studio-${domain_id}:latest`)
#' @param compute_type (character): The [`CodeBuild`](https://aws.amazon.com/codebuild/) compute type (default: `BUILD_GENERAL1_SMALL`)
#' @param role (character): The `IAM` role name for `CodeBuild` to use (default: the Studio execution role).
#' @param dir (character): Directory to build
#' @param bucket (character): The S3 bucket to use for sending data to `CodeBuild` (if None,
#' use the `SageMaker SDK` default bucket).
#' @param vpc_id (character): The Id of the `VPC` that will host the `CodeBuild` Project
#' (such as `vpc-05c09f91d48831c8c`).
#' @param subnet_ids (list): List of `subnet` ids for the `CodeBuild` Project
#' (such as `subnet-0b31f1863e9d31a67`)
#' @param security_group_ids (list): List of security group ids for
#' the `CodeBuild` Project (such as `sg-0ce4ec0d0414d2ddc`).
#' @param log (logical): Show the logs of the running `CodeBuild` build
#' @param ... docker build parameters
#' <https://docs.docker.com/engine/reference/commandline/build/#options>
#' (NOTE: use "_" instead of "-" for example: docker optional parameter
#' \code{build-arg} becomes \code{build_arg})
#' @examples
#' \dontrun{
#' # Execute on current directory.
#' vetiver_sm_build()
#'
#' # Execute on different directory.
#' vetiver_sm_build(dir = "my-project")
#'
#' # Add extra docker arguments
#' vetiver_sm_build(
#'   file = "/path/to/Dockerfile",
#'   build_arg = "foo=bar"
#' )
#' }
#' @return invisible character vector of `AWS ECR` image `uri`.
#' @export
vetiver_sm_build <- function(repository = NULL,
                             compute_type = c(
                               "BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM",
                               "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"
                             ),
                             role = NULL,
                             dir = ".",
                             bucket = NULL,
                             vpc_id = NULL,
                             subnet_ids = list(),
                             security_group_ids = list(),
                             log = TRUE,
                             ...) {
  rlang::check_installed("smdocker")
  image_uri <- smdocker::sm_build(
    repository = repository,
    compute_type = compute_type,
    role = role,
    dir = dir,
    bucket = bucket,
    vpc_id = vpc_id,
    subnet_ids = subnet_ids,
    security_group_ids = security_group_ids,
    log = log,
    ...
  )
  return(image_uri)
}

#' @title Create a `Amazon SageMaker` Model.
#' @param image_uri The AWS ECR image uri for `Amazon SageMaker` Model
#' @param model_name The `Amazon SageMaker` model name (optional)
#' @param role The ARN role for the `Amazon SageMaker` model (optional)
#' @param vpc_config A list containing the `VPC` configuration for `Amazon SageMaker` model
#' [API VpcConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_VpcConfig.html) (optional).
#' * `Subnets`: List of subnet ids
#' * `SecurityGroupIds`: List of security group ids.
#' @param enable_network_isolation Specifies whether container will
#' run in network isolation mode.
#' @param tags A list of tags for labeling `Amazon SageMaker` Model.
#' @return Character vector of the model name
#' @export
vetiver_sm_model <- function(image_uri,
                             model_name,
                             role,
                             vpc_config = list(),
                             enable_network_isolation = FALSE,
                             tags = NULL) {
  rlang::check_installed(c("smdocker", "paws.machine.learning"))
  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)

  if (missing(model_name)) {
    # NOTE: model name needs to meet regex:
    # ^[a-zA-Z0-9]([\-a-zA-Z0-9]*[a-zA-Z0-9])?
    # Should there be a check or a clean up of name coming from ecr image?
    model_name <- base_name_from_image(image_uri)
  }

  if (missing(role)) {
    role <- smdocker::sagemaker_get_execution_role()
  }

  request <- list(
    "ModelName" = model_name,
    "ExecutionRoleArn" = role,
    "PrimaryContainer" = list("Image" = image_uri)
  )
  request$Tags <- .append_project_tags(tags)
  request$VpcConfig <- get_vpc_config(vpc_config)
  if (isTRUE(enable_network_isolation)) {
    request$EnableNetworkIsolation <- TRUE
  }
  # create model
  do.call(sagemaker_client$create_model, request)

  return(model_name)
}

#' @title Create a `Amazon SageMaker` Model endpoint.
#' @param model_name The `Amazon SageMaker` model name
#' @param endpoint_name The name to use for `Amazon SageMaker` model endpoint.
#' @param instance_type Type of EC2 instance to use
#' [Amazon SageMaker Pricing](https://aws.amazon.com/sagemaker/pricing/).
#' @param initial_instance_count The initial number of instances to run
#' in the `Endpoint`.
#' @param accelerator_type Type of Elastic Inference accelerator to
#' attach to an endpoint for model loading and inference, for
#' example, 'ml.eia1.medium'.
#' @param tags A list of tags for labeling `Amazon SageMaker` Model.
#' @param kms_key The ARN of the KMS key that is used to encrypt the
#' data on the storage volume attached to the instance hosting the
#' endpoint.
#' @param data_capture_config A list configuration to control how `Amazon SageMaker`
#' captures inference data.
#' @param volume_size The size, in GB, of the ML storage volume attached to individual
#' inference instance associated with the production variant. Currenly only Amazon EBS
#' gp2 storage volumes are supported.
#' @param model_data_download_timeout The timeout value, in seconds, to download and
#' extract model data from `Amazon S3`.
#' @param wait Wait for the endpoint to be deployed.
#' @return A new [vetiver_endpoint_sagemaker()] object
#' @export
vetiver_sm_endpoint <- function(model_name,
                                endpoint_name = NULL,
                                instance_type = NULL,
                                initial_instance_count = 1,
                                accelerator_type = NULL,
                                tags = NULL,
                                kms_key = NULL,
                                data_capture_config = NULL,
                                volume_size = NULL,
                                model_data_download_timeout = NULL,
                                wait = TRUE) {
  rlang::check_installed(c("smdocker", "paws.machine.learning"))

  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)

  endpoint_name <- endpoint_name %||% model_name

  request <- req_endpoint_config(
    model_name,
    endpoint_name,
    instance_type,
    initial_instance_count,
    accelerator_type,
    volume_size,
    model_data_download_timeout,
    .append_project_tags(tags),
    kms_key,
    data_capture_config
  )

  # create endpoint config
  resp <- do.call(
    sagemaker_client$create_endpoint_config,
    request
  )

  # create endpoint
  endpoint_name <- create_endpoint(
    sagemaker_client, model_name, endpoint_name, tags, wait
  )

  return(vetiver_endpoint_sagemaker(model_name))
}

#' @title Delete `Amazon SageMaker` endpoint and configuration.
#' @param object A model API endpoint object created with [vetiver_endpoint_sagemaker()].
#' @param delete_endpoint_config Delete endpoint configuration (default: `TRUE`).
#' @return `TRUE` invisible
#' @export
vetiver_sm_delete <- function(object, delete_endpoint_config = TRUE) {
  rlang::check_installed(c("smdocker", "paws.machine.learning"))

  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)

  endpoint_name <- object$model_endpoint

  if (!is.null(delete_endpoint_config)) {
    tryCatch(
      {
        endpoint_config_name <- sagemaker_client$describe_endpoint(
          EndpointName = endpoint_name
        )$EndpointConfigName
        sagemaker_client$delete_endpoint_config(endpoint_config_name)
      },
      error = function(err) {
        warn(glue("Unable to delete '{endpoint_name}' endpoint configuration."))
      }
    )
  }
  sagemaker_client$delete_model(endpoint_name)
  sagemaker_client$delete_endpoint(endpoint_name)
  return(invisible(TRUE))
}

#' Post new data to a deployed model API endpoint and return predictions
#'
#' @param object A model API endpoint object created with [vetiver_endpoint_sagemaker()].
#' @param new_data New data for making predictions, such as a data frame.
#' @param ... Extra arguments passed to [httr::POST()]
#'
#' @return A tibble of model predictions with as many rows as in `new_data`.
#' @importFrom stats predict
#' @seealso [augment.vetiver_endpoint_sagemaker()]
#' @export
#'
#' @examples
#'
#' if (FALSE) {
#'   endpoint <- vetiver_endpoint_sagemaker("sagemaker-demo-model")
#'   predict(endpoint, mtcars[4:7, -1])
#' }
#' @export
predict.vetiver_endpoint_sagemaker <- function(object, new_data, ...) {
  rlang::check_installed(c("jsonlite", "smdocker", "paws.machine.learning"))
  data_json <- jsonlite::toJSON(new_data, na = "string")
  config <- smdocker::smdocker_config()
  sm_runtime <- paws.machine.learning::sagemakerruntime(config)
  tryCatch(
    {
        resp <- sm_runtime$invoke_endpoint(object$model_endpoint, data_json)$Body
    },
    error = function(error) {
      error_code <- error$error_response$ErrorCode
      if (error_code == "NO_SUCH_ENDPOINT") {
        abort(glue("Model Endpoint '{object$model_endpoint}' not found."))
      }
      stop(error)
    }
  )
  con <- rawConnection(resp)
  on.exit(close(con))
  resp <- jsonlite::fromJSON(con)
  return(tibble::as_tibble(resp))
}

#' Post new data to a deployed model API endpoint and augment with predictions
#'
#' @param x A model API endpoint object created with [vetiver_endpoint_sagemaker()].
#' @inheritParams predict.vetiver_endpoint_sagemaker
#'
#' @return The `new_data` with added prediction column(s).
#' @seealso [predict.vetiver_endpoint_sagemaker()]
#' @export
#'
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


#' Create a model API endpoint object for prediction
#'
#' This function creates a model API endpoint for prediction from a Sagemaker Model.
#' No HTTP calls are made until you actually
#' [`predict()`][predict.vetiver_endpoint_sagemaker()] with your endpoint.
#'
#' @param model_endpoint An Amazon SageMaker Model endpoint.
#' @return A new `vetiver_endpoint_sagemaker` object
#'
#' @examples
#'
#' if (FALSE) {
#' vetiver_endpoint("vetiver-sagemaker-demo-model")
#' }
#' @export
vetiver_endpoint_sagemaker <- function(model_endpoint) {
  rlang::check_installed("smdocker")
  config <- smdocker::smdocker_config()
  model_endpoint <- as.character(model_endpoint)
  new_vetiver_endpoint_sagemaker(model_endpoint, config$region)
}

new_vetiver_endpoint_sagemaker <- function(model_endpoint = character(),
                                           region = character()) {
  stopifnot(is.character(model_endpoint), is.character(region))
  structure(
    list(model_endpoint = model_endpoint, region = region),
    class = "vetiver_endpoint_sagemaker"
  )
}

#' @export
format.vetiver_endpoint_sagemaker <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_h3("A SageMaker model endpoint for prediction:")
    cli::cli_text("Model Endpoint: {x$model_endpoint}")
    cli::cli_text("Region: {x$region}")
  })
}

#' @export
print.vetiver_endpoint_sagemaker <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
