# Deploy a vetiver model API to Amazon SageMaker

Use `vetiver_deploy_sagemaker()` to deploy a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
that has been versioned and stored via
[`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md)
as a Plumber API on [Amazon
SageMaker](https://aws.amazon.com/sagemaker/).

## Usage

``` r
vetiver_deploy_sagemaker(
  board,
  name,
  instance_type,
  ...,
  predict_args = list(),
  docker_args = list(),
  build_args = list(),
  endpoint_args = list(),
  repo_name = glue("vetiver-sagemaker-{name}")
)
```

## Arguments

- board:

  An AWS S3 board created with
  [`pins::board_s3()`](https://pins.rstudio.com/reference/board_s3.html).
  This board must be in the correct region for your SageMaker instance.

- name:

  Pin name.

- instance_type:

  Type of EC2 instance to use; see [Amazon SageMaker
  pricing](https://aws.amazon.com/sagemaker/pricing/).

- ...:

  Not currently used.

- predict_args:

  A list of optional arguments passed to
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  such as the prediction `type`.

- docker_args:

  A list of optional arguments passed to
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_docker.md)
  such as the `lockfile` name or whether to use `rspm`. Do not pass
  `additional_pkgs` here, as this function uses
  `additional_pkgs = required_pkgs(board)`.

- build_args:

  A list of optional arguments passed to
  [`vetiver_sm_build()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  such as the model `version` or the `compute_type`.

- endpoint_args:

  A list of optional arguments passed to
  [`vetiver_sm_endpoint()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  such as `accelerator_type` or `data_capture_config`.

- repo_name:

  The name for the AWS ECR repository to store the model.

## Value

The deployed
[`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_endpoint_sagemaker.md).

## Details

This function stores your model deployment image in the same bucket used
by `board`.

The function `vetiver_deploy_sagemaker()` uses:

- [`vetiver_sm_build()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  to build and push a Docker image to ECR,

- [`vetiver_sm_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  to create a SageMaker model, and

- [`vetiver_sm_endpoint()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  to deploy a SageMaker model endpoint.

These modular functions are available for more advanced use cases.

If you are working locally, you will likely need to explicitly set up
your execution role to work correctly. Check out ["Execution role
requirements"](https://dyfanjones.r-universe.dev/smdocker) in the
smdocker documentation, and especially note that the bucket containing
your vetiver model needs to be added as a resource in your IAM role
policy.

## See also

[`vetiver_sm_build()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md),
[`vetiver_sm_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md),
[`vetiver_sm_endpoint()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)

## Examples

``` r
if (FALSE) {
library(pins)
b <- board_s3(bucket = "my-existing-bucket")
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)

endpoint <- vetiver_deploy_sagemaker(
    board = b,
    name = "cars_linear",
    instance_type = "ml.t2.medium",
    predict_args = list(type = "class", debug = TRUE)
)
}
```
