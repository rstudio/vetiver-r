#' @import rlang
#' @importFrom stats predict

#' @include sagemaker_utils.R


# @export
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
#   image_uri <- smdocker::sm_build(
#       repository = repository,
#       compute_type = compute_type,
#       role = role,
#       dir = dir,
#       bucket = bucket,
#       vpc_id = vpc_id,
#       subnet_ids = subnet_ids,
#       security_group_ids = security_group_ids,
#       log = log,
#       ...
#   )
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
  rlang::check_installed(c("smdocker", "paws.machine.learning"))
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
vetiver_deploy_sagemaker_model <- function(model_name,
                                           endpoint_name = NULL,
                                           instance_type = NULL,
                                           initial_instance_count = 1,
                                           accelerator_type = NULL,
                                           tags = NULL,
                                           kms_key = NULL,
                                           data_capture_config = NULL,
                                           volume_size = NULL,
                                           model_data_download_timeout = NULL,
                                           container_startup_health_check_timeout = NULL,
                                           wait = TRUE) {
  rlang::check_installed(c("smdocker", "paws.machine.learning"))

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
vetiver_delete_sagemaker_model <- function(model_name) {
  rlang::check_installed(c("smdocker", "paws.machine.learning"))

  config <- smdocker::smdocker_config()
  sagemaker_client <- paws.machine.learning::sagemaker(config)
  sagemaker_client$delete_model(model_name)
}

#' @export
predict.vetiver_endpoint_sagemaker <- function(x, new_data, ...) {
  rlang::check_installed(c("jsonlite", "smdocker", "paws.machine.learning"))
  data_json <- jsonlite::toJSON(new_data, na = "string")
  config <- smdocker::smdocker_config()
  sm_runtime <- paws.machine.learning::sagemakerruntime(config)
  resp <- sm_runtime$invoke_endpoint(sm_model_name, data_json)$Body
  con <- rawConnection(resp)
  on.exit(close(con))
  resp <- jsonlite::fromJSON(con)
  return(tibble::as_tibble(resp))
}

# classes and formatting

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
