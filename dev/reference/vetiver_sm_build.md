# Deploy a vetiver model API to Amazon SageMaker with modular functions

Use the function
[`vetiver_deploy_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_sagemaker.md)
for basic deployment on [SageMaker](https://aws.amazon.com/sagemaker/),
or these three functions together for more advanced use cases:

- `vetiver_sm_build()` generates and builds a Docker image on SageMaker
  for a vetiver model

- `vetiver_sm_model()` creates an Amazon SageMaker model

- `vetiver_sm_endpoint()` deploys an Amazon SageMaker model endpoint

## Usage

``` r
vetiver_sm_build(
  board,
  name,
  version = NULL,
  path = fs::dir_create(tempdir(), "vetiver"),
  predict_args = list(),
  docker_args = list(),
  repository = NULL,
  compute_type = c("BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM",
    "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"),
  role = NULL,
  bucket = NULL,
  vpc_id = NULL,
  subnet_ids = list(),
  security_group_ids = list(),
  log = TRUE,
  ...
)

vetiver_sm_model(
  image_uri,
  model_name,
  role = NULL,
  vpc_config = list(),
  enable_network_isolation = FALSE,
  tags = list()
)

vetiver_sm_endpoint(
  model_name,
  instance_type,
  endpoint_name = NULL,
  initial_instance_count = 1,
  accelerator_type = NULL,
  tags = list(),
  kms_key = NULL,
  data_capture_config = list(),
  volume_size = NULL,
  model_data_download_timeout = NULL,
  wait = TRUE
)
```

## Arguments

- board:

  An AWS S3 board created with
  [`pins::board_s3()`](https://pins.rstudio.com/reference/board_s3.html).
  This board must be in the correct region for your SageMaker instance.

- name:

  Pin name.

- version:

  Retrieve a specific version of a pin. Use
  [`pin_versions()`](https://pins.rstudio.com/reference/pin_versions.html)
  to find out which versions are available and when they were created.

- path:

  A path to write the Plumber file, Dockerfile, and lockfile, capturing
  the model's dependencies.

- predict_args:

  A list of optional arguments passed to
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md)
  such as the prediction `type`.

- docker_args:

  A list of optional arguments passed to
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_docker.md)
  such as the `lockfile` name or whether to use `rspm`. Do not pass
  `additional_pkgs` here, as this function uses
  `additional_pkgs = required_pkgs(board)`.

- repository:

  The ECR repository and tag for the image as a character. Defaults to
  `sagemaker-studio-${domain_id}:latest`.

- compute_type:

  The [CodeBuild](https://aws.amazon.com/codebuild/) compute type as a
  character. Defaults to `BUILD_GENERAL1_SMALL`.

- role:

  The ARN IAM role name (as a character) to be used with:

  - CodeBuild for `vetiver_sm_build()`

  - the SageMaker model for `vetiver_sm_model()`

  Defaults to the SageMaker Studio execution role.

- bucket:

  The S3 bucket to use for sending data to CodeBuild as a character.
  Defaults to the SageMaker SDK default bucket.

- vpc_id:

  ID of the VPC that will host the CodeBuild project such as
  `"vpc-05c09f91d48831c8c"`.

- subnet_ids:

  List of subnet IDs for the CodeBuild project, such as
  `list("subnet-0b31f1863e9d31a67")`.

- security_group_ids:

  List of security group IDs for the CodeBuild project, such as
  `list("sg-0ce4ec0d0414d2ddc")`.

- log:

  A logical to show the logs of the running CodeBuild build. Defaults to
  `TRUE`.

- ...:

  [Docker build
  parameters](https://docs.docker.com/engine/reference/commandline/build/#options%3E)
  (Use "\_" instead of "-"; for example, Docker optional parameter
  `build-arg` becomes `build_arg`).

- image_uri:

  The AWS ECR image URI for the Amazon SageMaker Model to be created
  (for example, as returned by `vetiver_sm_build()`).

- model_name:

  The Amazon SageMaker model name to be deployed.

- vpc_config:

  A list containing the VPC configuration for the Amazon SageMaker model
  [API
  VpcConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_VpcConfig.html)
  (optional).

  - `Subnets`: List of subnet ids

  - `SecurityGroupIds`: List of security group ids

- enable_network_isolation:

  A logical to specify whether the container will run in network
  isolation mode. Defaults to `FALSE`.

- tags:

  A named list of tags for labeling the Amazon SageMaker model or model
  endpint to be created.

- instance_type:

  Type of EC2 instance to use; see [Amazon SageMaker
  pricing](https://aws.amazon.com/sagemaker/pricing/).

- endpoint_name:

  The name to use for the Amazon SageMaker model endpoint to be created,
  if to be different from `model_name`.

- initial_instance_count:

  The initial number of instances to run in the endpoint.

- accelerator_type:

  Type of Elastic Inference accelerator to attach to an endpoint for
  model loading and inference, for example, `"ml.eia1.medium"`.

- kms_key:

  The ARN of the KMS key used to encrypt the data on the storage volume
  attached to the instance hosting the endpoint.

- data_capture_config:

  A list for configuration to control how Amazon SageMaker captures
  inference data.

- volume_size:

  The size, in GB, of the ML storage volume attached to the individual
  inference instance associated with the production variant. Currently
  only Amazon EBS gp2 storage volumes are supported.

- model_data_download_timeout:

  The timeout value, in seconds, to download and extract model data from
  Amazon S3.

- wait:

  A logical for whether to wait for the endpoint to be deployed.
  Defaults to `TRUE`.

## Value

`vetiver_sm_build()` returns the AWS ECR image URI and
`vetiver_sm_model()` returns the model name (both as characters).
`vetiver_sm_endpoint()` returns a new
[`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md)
object.

## Details

The function `vetiver_sm_build()` generates the files necessary to build
a Docker container to deploy a vetiver model in SageMaker and then
builds the image on [AWS CodeBuild](https://aws.amazon.com/codebuild/).
The resulting image is stored in [AWS ECR](https://aws.amazon.com/ecr/).
This function creates a Plumber file and Dockerfile appropriate for
SageMaker, for example, with `path = "/invocations"` and `port = 8080`.

If you run into problems with Docker rate limits, then either

- authenticate to Docker from SageMaker, or

- use a [public ECR base
  image](https://gallery.ecr.aws/docker/library/r-base), passed through
  `docker_args`

## See also

[`vetiver_prepare_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_prepare_docker.md),
[`vetiver_deploy_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_sagemaker.md),
[`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md)

## Examples

``` r
if (FALSE) {
library(pins)
b <- board_s3(bucket = "my-existing-bucket")
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)

new_image_uri <- vetiver_sm_build(
    board = b,
    name = "cars_linear",
    predict_args = list(type = "class", debug = TRUE),
    docker_args = list(
        base_image = "FROM public.ecr.aws/docker/library/r-base:4.2.2"
    )
)

model_name <- vetiver_sm_model(
    new_image_uri,
    tags = list("my_custom_tag" = "fuel_efficiency")
)

vetiver_sm_endpoint(model_name, "ml.t2.medium")
}
```
