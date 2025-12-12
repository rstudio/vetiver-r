# Post new data to a deployed SageMaker model endpoint and augment with predictions

Post new data to a deployed SageMaker model endpoint and augment with
predictions

## Usage

``` r
# S3 method for class 'vetiver_endpoint_sagemaker'
augment(x, new_data, ...)
```

## Arguments

- x:

  A SageMaker model endpoint object created with
  [`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md).

- new_data:

  New data for making predictions, such as a data frame.

- ...:

  Extra arguments passed to
  [`paws.machine.learning::sagemakerruntime_invoke_endpoint()`](https://paws-r.r-universe.dev/paws.machine.learning/reference/sagemakerruntime_invoke_endpoint.html)

## Value

The `new_data` with added prediction column(s).

## See also

[`predict.vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/predict.vetiver_endpoint_sagemaker.md)

## Examples

``` r
if (FALSE) {
  endpoint <- vetiver_endpoint_sagemaker("sagemaker-demo-model")
  augment(endpoint, mtcars[4:7, -1])
}
```
