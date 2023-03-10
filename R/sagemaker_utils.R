#' @import rlang
#' @importFrom utils flush.console

get_vpc_config <- function(vpc_config) {
  if (is_empty(vpc_config)) {
    return(NULL)
  }
  subnet <- vpc_config$Subnets
  if (is_empty(subnet)) {
    abort("missing Subnets from vpc_config")
  } else if (!is.list(subnet)) {
    abort("Subnets in wrong format, requires to be a list")
  }
  security_group_ids <- vpc_config$SecurityGroupIds
  if (is_empty(security_group_ids)) {
    abort("missing SecurityGroupIds from vpc_config")
  } else if (!is.list(security_group_ids)) {
    abort("SecurityGroupIds in wrong format, requires to be a list")
  }
  return(vpc_config)
}

base_name_from_image <- function(image) {
  m <- regexec("^(.+/)?([^:/]+)(:[^:]+)?$", image)
  image_name <- if (!is.null(m)) unlist(regmatches(image, m))[[3]] else image
  now <- Sys.time()
  now_ms <- strsplit(format(as.numeric(now, 3), nsmall = 3), split = "\\.")[[1]][[2]]
  timestamp <- format(now, paste0("%Y-%m-%d-%H-%M-%S-", now_ms))
  image_name <- substring(image_name, 1, (63L - nchar(timestamp) - 1))
  return(sprintf("%s-%s", image_name, timestamp))
}

req_endpoint_config <- function(model_name,
                                endpoint_name,
                                instance_type,
                                initial_instance_count,
                                accelerator_type,
                                volume_size,
                                model_data_download_timeout,
                                tags,
                                kms_key,
                                data_capture_config) {
  request <- list(EndpointConfigName = endpoint_name)

  product_variant <- list(
    ModelName = model_name,
    VariantName = "AllTraffic",
    InitialVariantWeight = 1
  )
  product_variant$AcceleratorType <- accelerator_type
  product_variant$InitialInstanceCount <- initial_instance_count
  product_variant$InstanceType <- instance_type
  product_variant$VolumeSizeInGB <- if(is.null(volume_size)) NULL else as.integer(volume_size)
  product_variant$ModelDataDownloadTimeoutInSeconds <- (
      if(is.null(model_data_download_timeout)) NULL else as.integer(model_data_download_timeout)
  )
  request$ProductionVariants <- list(product_variant)
  request$Tags <- tags
  request$KmsKeyId <- kms_key
  request$DataCaptureConfig <- data_capture_config
  return(request)
}

# sagemaker helper functions
create_endpoint <- function(client,
                            endpoint_name,
                            config_name,
                            tags = NULL,
                            wait = TRUE) {
  inform(sprintf("Creating endpoint with name %s", endpoint_name))

  tags <- tags %||% list()

  client$create_endpoint(
    EndpointName = endpoint_name, EndpointConfigName = config_name, Tags = tags
  )
  if (isTRUE(wait)) {
    wait_for_endpoint(client, endpoint_name)
  }
  return(endpoint_name)
}

# developed from:
# https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/session.py#L3753-L3786
wait_for_endpoint <- function(client, endpoint, poll = 30) {
  desc <- sagemaker_deploy_done(client, endpoint)
  while (is_empty(desc)) {
    Sys.sleep(poll)
    desc <- sagemaker_deploy_done(client, endpoint)
  }
  status <- desc$EndpointStatus
  if (status != "InService") {
    reason <- desc$FailureReason
    message <- sprintf(
      "Error hosting endpoint %s: %s. Reason: %s.", endpoint, status, reason
    )
    if (grepl("CapacityError", as.character(reason))) {
      abort(message, class = "CapacityError")
    }
    abort(message, class = "UnexpectedStatusException")
  }
  return(desc)
}

# developed from:
# https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/session.py#L5809-L5828
sagemaker_deploy_done <- function(client, endpoint_name) {
  hosting_status_codes <- list(
    "OutOfService" = "x",
    "Creating" = "-",
    "Updating" = "-",
    "InService" = "!",
    "RollingBack" = "<",
    "Deleting" = "o",
    "Failed" = "*"
  )
  in_progress_statuses <- c("Creating", "Updating")

  desc <- client$describe_endpoint(EndpointName = endpoint_name)
  status <- desc$EndpointStatus

  msg <- hosting_status_codes[[status]]
  if (is.null(msg)) msg <- "?"

  write_to_console(msg, sep = "")

  if (status %in% in_progress_statuses) {
    return(NULL)
  }

  write_to_console("")
  return(desc)
}

# developed from:
# https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/_studio.py#L21-L113
STUDIO_PROJECT_CONFIG <- ".sagemaker-code-config"

.append_project_tags <- function(tags = NULL, working_dir = NULL) {
  path <- .find_config(working_dir)
  if (is.null(path)) {
    return(tags)
  }

  config <- .load_config(path)
  if (is.null(config)) {
    return(tags)
  }

  additional_tags <- .parse_tags(config)
  if (is.null(additional_tags)) {
    return(tags)
  }

  all_tags <- tags %||% list()
  all_tags <- c(all_tags, additional_tags)

  return(all_tags)
}

.find_config <- function(working_dir = NULL) {
  tryCatch(
    {
      wd <- if (!is.null(working_dir)) working_dir else getwd()
      path <- NULL
      while (is.null(path) && !grepl("/", wd)) {
        candidate <- fs::path(wd, STUDIO_PROJECT_CONFIG)
        if (fs::file_exists(candidate)) {
          path <- candidate
        }
        wd <- fs::path_dir(candidate)
      }
      return(path)
    },
    error = function(e) {
      return(NULL)
    }
  )
}

.load_config <- function(path) {
  if (!fs::file_exists(path)) {
    return(NULL)
  }
  tryCatch(
    {
      config <- jsonlite::read_json(path)
      return(config)
    },
    error = function(e) {
      return(NULL)
    }
  )
}

.parse_tags <- function(config) {
  if (!is_empty(config$sagemakerProjectId) || !is_empty(config$sagemakerProjectName)) {
    return(list(
      list("Key" = "sagemaker:project-id", "Value" = config$sagemakerProjectId),
      list("Key" = "sagemaker:project-name", "Value" = config$sagemakerProjectName)
    ))
  } else {
    return(NULL)
  }
}

# allow to write to jupyter console while code still executing
# https://github.com/paws-r/paws/pull/602
write_to_console <- function(msg, sep = "\n") {
  on.exit(flush.console())
  writeLines(msg, sep = sep)
}
