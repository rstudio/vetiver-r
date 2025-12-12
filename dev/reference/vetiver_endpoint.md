# Create a model API endpoint object for prediction

This function creates a model API endpoint for prediction from a URL. No
HTTP calls are made until you actually
[`predict()`](https://rstudio.github.io/vetiver-r/dev/reference/predict.vetiver_endpoint.md)
with your endpoint.

## Usage

``` r
vetiver_endpoint(url)
```

## Arguments

- url:

  An API endpoint URL

## Value

A new `vetiver_endpoint` object

## Examples

``` r
vetiver_endpoint("https://colorado.rstudio.com/rsc/seattle-housing/predict")
#> 
#> ── A model API endpoint for prediction: 
#> https://colorado.rstudio.com/rsc/seattle-housing/predict
```
