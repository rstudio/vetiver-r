# Create a SageMaker model API endpoint object for prediction

This function creates a model API endpoint for prediction from a
Sagemaker Model. No HTTP calls are made until you actually
[`predict()`](https://rstudio.github.io/vetiver-r/reference/predict.vetiver_endpoint_sagemaker.md)
with your endpoint.

## Usage

``` r
vetiver_endpoint_sagemaker(model_endpoint)
```

## Arguments

- model_endpoint:

  The name of the Amazon SageMaker model endpoint.

## Value

A new `vetiver_endpoint_sagemaker` object

## Examples

``` r
vetiver_endpoint_sagemaker("vetiver-sagemaker-demo-model")
#> 
#> ── A SageMaker model endpoint for prediction: 
#> Model endpoint: vetiver-sagemaker-demo-model
#> Region:
```
