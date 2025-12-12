# Delete Amazon SageMaker model, endpoint, and endpoint configuration

Use this function to delete the Amazon SageMaker components used in a
[`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md)
object. This function does *not* delete any pinned model object in S3.

## Usage

``` r
vetiver_sm_delete(object, delete_model = TRUE, delete_endpoint = TRUE)
```

## Arguments

- object:

  The model API endpoint object to be deleted, created with
  [`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md).

- delete_model:

  Delete the SageMaker model? Defaults to `TRUE`.

- delete_endpoint:

  Delete both the endpoint and endpoint configuration? Defaults to
  `TRUE`.

## Value

`TRUE`, invisibly

## See also

[`vetiver_deploy_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_sagemaker.md),
[`vetiver_sm_build()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_sm_build.md),
[`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md)
