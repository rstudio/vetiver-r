# Post new data to a deployed SageMaker model endpoint and return predictions

Post new data to a deployed SageMaker model endpoint and return
predictions

## Usage

``` r
# S3 method for class 'vetiver_endpoint_sagemaker'
predict(object, new_data, ...)
```

## Arguments

- object:

  A SageMaker model endpoint object created with
  [`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md).

- new_data:

  New data for making predictions, such as a data frame.

- ...:

  Extra arguments passed to
  [`paws.machine.learning::sagemakerruntime_invoke_endpoint()`](https://paws-r.r-universe.dev/paws.machine.learning/reference/sagemakerruntime_invoke_endpoint.html)

## Value

A tibble of model predictions with as many rows as in `new_data`.

## See also

[`augment.vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/augment.vetiver_endpoint_sagemaker.md)

## Examples

``` r
if (FALSE) {
  endpoint <- vetiver_endpoint_sagemaker("sagemaker-demo-model")
  predict(endpoint, mtcars[4:7, -1])
}
```
