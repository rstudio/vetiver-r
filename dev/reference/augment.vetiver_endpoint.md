# Post new data to a deployed model API endpoint and augment with predictions

Post new data to a deployed model API endpoint and augment with
predictions

## Usage

``` r
# S3 method for class 'vetiver_endpoint'
augment(x, new_data, ...)
```

## Arguments

- x:

  A model API endpoint object created with
  [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md).

- new_data:

  New data for making predictions, such as a data frame.

- ...:

  Extra arguments passed to
  [`httr::POST()`](https://httr.r-lib.org/reference/POST.html)

## Value

The `new_data` with added prediction column(s).

## See also

[`predict.vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/predict.vetiver_endpoint.md)

## Examples

``` r
if (FALSE) {
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
augment(endpoint, mtcars[4:7, -1])
}
```
