# Post new data to a deployed model API endpoint and return predictions

Post new data to a deployed model API endpoint and return predictions

## Usage

``` r
# S3 method for class 'vetiver_endpoint'
predict(object, new_data, ...)
```

## Arguments

- object:

  A model API endpoint object created with
  [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md).

- new_data:

  New data for making predictions, such as a data frame.

- ...:

  Extra arguments passed to
  [`httr::POST()`](https://httr.r-lib.org/reference/POST.html)

## Value

A tibble of model predictions with as many rows as in `new_data`.

## See also

[`augment.vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/augment.vetiver_endpoint.md)

## Examples

``` r
if (FALSE) {
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
predict(endpoint, mtcars[4:7, -1])
}

```
