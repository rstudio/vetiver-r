sm_check_vpc_config <- function(vpc_config, call = caller_env()) {
    if (is_empty(vpc_config)) {
        return(NULL)
    }
    subnet <- vpc_config$Subnets
    if (is_empty(subnet) || !inherits(subnet, "list")) {
        stop_input_type(subnet, "a list", call = call)
    }
    security_group_ids <- vpc_config$SecurityGroupIds
    if (is_empty(security_group_ids) || !inherits(security_group_ids, "list")) {
        stop_input_type(security_group_ids, "a list", call = call)
    }
    return(vpc_config)
}

base_name_from_image <- function(image) {
    # NOTE: model name needs to meet regex:
    # ^[a-zA-Z0-9]([\-a-zA-Z0-9]*[a-zA-Z0-9])?
    # Should there be a check or a clean up of name coming from ecr image?
    m <- regexec("^(.+/)?([^:/]+)(:[^:]+)?$", image)
    image_name <- if (!is.null(m)) unlist(regmatches(image, m))[[3]] else image
    now <- Sys.time()
    timestamp <- gsub("\\.", "-", strftime(now, "%Y-%m-%d-%H-%M-%OS3"))
    image_name <- substring(image_name, 1, (63L - nchar(timestamp) - 1))
    return(sprintf("%s-%s", image_name, timestamp))
}

sm_req_endpoint_config <- function(model_name,
                                   endpoint_name,
                                   instance_type,
                                   initial_instance_count,
                                   accelerator_type,
                                   volume_size,
                                   model_data_download_timeout,
                                   tags,
                                   kms_key,
                                   data_capture_config) {

    volume_size <- return_null_or_integer(volume_size)
    model_data_download_timeout <- return_null_or_integer(model_data_download_timeout)

    request <- compact(list(
        EndpointConfigName = endpoint_name,
        ProductionVariants = list(compact(list(
            ModelName = model_name,
            VariantName = "AllTraffic",
            InitialVariantWeight = 1,
            AcceleratorType = accelerator_type,
            InitialInstanceCount = initial_instance_count,
            InstanceType = instance_type,
            VolumeSizeInGB = volume_size,
            ModelDataDownloadTimeoutInSeconds = model_data_download_timeout
        ))),
        Tags = tags,
        KmsKeyId = kms_key,
        DataCaptureConfig = data_capture_config
    ))

    return(request)
}

return_null_or_integer <- function(x) {
    if (is.null(x)) NULL else as.integer(x)
}

# sagemaker helper functions
sm_create_endpoint <- function(client,
                               endpoint_name,
                               config_name,
                               tags = list(),
                               wait = TRUE) {
    cli::cli_inform("Creating endpoint with name {.val {endpoint_name}}")

    client$create_endpoint(
        EndpointName = endpoint_name, EndpointConfigName = config_name, Tags = tags
    )
    if (isTRUE(wait)) {
        sm_wait_for_endpoint(client, endpoint_name)
    }
    return(endpoint_name)
}

# developed from:
# https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/session.py#L3753-L3786
sm_wait_for_endpoint <- function(client, endpoint, poll = 30, call = caller_env()) {
    desc <- sagemaker_deploy_done(client, endpoint)
    while (is_empty(desc)) {
        Sys.sleep(poll)
        desc <- sagemaker_deploy_done(client, endpoint)
    }
    status <- desc$EndpointStatus
    if (status != "InService") {
        reason <- desc$FailureReason
        message <- c(
            "Error hosting endpoint {.val {endpoint}}: {status}",
            "Reason: {reason}"
        )
        if (grepl("CapacityError", as.character(reason))) {
            cli::cli_abort(message, class = "CapacityError", call = call)
        }
        cli::cli_abort(message, class = "UnexpectedStatusException", call = call)
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

sm_check_tags <- function(tags, call = caller_env(), arg = caller_arg(tags)) {
    if (is_empty(tags)) {
        return(list())
    }
    if (!inherits(tags, "list")) {
        stop_input_type(tags, "a list", call = call)
    }
    if (!is_named(tags)) {
        cli::cli_abort('{.arg {arg}} must have valid names, like {.code list("my-tag" = "my-value")}', call = call)
    }
    return(tags)
}

sm_format_tags <- function(tags) {
    tags <- lapply(names(tags), function(n) list(Key = n, Value = tags[[n]]))
    return(tags)
}

.sm_append_project_tags <- function(tags = NULL, working_dir = NULL) {
    path <- .sm_find_config(working_dir)
    if (is.null(path)) {
        return(tags)
    }

    config <- .sm_load_config(path)
    if (is.null(config)) {
        return(tags)
    }

    additional_tags <- .sm_parse_tags(config)
    if (is.null(additional_tags)) {
        return(tags)
    }

    all_tags <- tags %||% list()
    all_tags <- c(all_tags, additional_tags)

    return(all_tags)
}

.sm_find_config <- function(working_dir = NULL) {
    tryCatch(
        {
            wd <- working_dir %||% getwd()
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

.sm_load_config <- function(path) {
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

.sm_parse_tags <- function(config) {
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
