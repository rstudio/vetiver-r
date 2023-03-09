#' @import rlang
#' @importFrom jsonlite fromJSON
#' @importFrom stats predict


#' @include sagemaker_utils.R

# TODO: tidy up!
# Should classes be used to help with flow?

# helper function
# vetiver_create_aws_ecr <- function(repository = NULL,
#                                    compute_type = c(
#                                      "BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM",
#                                      "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"
#                                    ),
#                                    role = NULL,
#                                    dir = ".",
#                                    bucket = NULL,
#                                    vpc_id = NULL,
#                                    subnet_ids = list(),
#                                    security_group_ids = list(),
#                                    log = TRUE,
#                                    ...) {
#   if (!is_installed("smdocker")) {
#     abort("smdocker not installed")
#   }
#   image_uri <- smdocker::sm_build()
#
#   return(image_uri)
# }

#' @title initial create sagemaker model from vetiver
#' @export
vetiver_create_sagemaker_model <- function(model_name,
                                           role,
                                           image_uri,
                                           vpc_config = list(),
                                           enable_network_isolation = FALSE,
                                           tags = NULL) {
  if (!is_installed("smdocker")) {
    abort("smdocker not installed")
  }
  if (!is_installed("paws.machine.learning")) {
    abort("paws.machine.learning not installed")
  }

  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)

  if (missing(model_name)) {
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
  request$Tags <- tags
  request$VpcConfig <- get_vpc_config(vpc_config)
  if (isTRUE(enable_network_isolation)) {
    request$EnableNetworkIsolation <- TRUE
  }
  # create model
  do.call(sagemaker_client$create_model, request)

  return(model_name)
}

#' @export
vetiver_deploy_sagemaker <- function(model_name,
                                     endpoint_name = NULL,
                                     instance_type = NULL,
                                     initial_instance_count = 1,
                                     accelerator_type = NULL,
                                     tags = NULL,
                                     kms_key = NULL,
                                     data_capture_config = NULL,
                                     volume_size = NULL,
                                     model_data_download_timeout = NULL,
                                     container_startup_health_check_timeout = NULL) {
  if (!is_installed("smdocker")) {
    abort("smdocker not installed")
  }
  if (!is_installed("paws.machine.learning")) {
    abort("paws.machine.learning not installed")
  }

  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)

  request <- req_endpoint_config(
    model_name,
    endpoint_name,
    instance_type,
    initial_instance_count,
    accelerator_type,
    volume_size,
    model_data_download_timeout,
    tags,
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

  return(new_vetiver_endpoint_sagemaker(model_name))
}

#' @export
predict.sagemaker <- function(x, new_data, ...) {
  config <- smdocker::smdocker_config()
  sm_runtime <- paws.machine.learning::sagemakerruntime(config)
  preds <- sm_runtime$invoke_endpoint(sm_model_name, new_data)$Body
  con <- rawConnection(stream)
  on.exit(close(con))
  return(fromJSON(con))
}

new_vetiver_endpoint_sagemaker <- function(model_name = character()) {
  stopifnot(is.character(model_name))
  structure(list(model_name = model_name), class = "vetiver_endpoint_sagemaker")
}

#' @export
format.vetiver_endpoint_sagemaker <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_h3("A model API endpoint for prediction:")
    cli::cli_text("{x$model_name}")
  })
}

#' @export
print.vetiver_endpoint_sagemaker <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
