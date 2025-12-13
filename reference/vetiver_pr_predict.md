# Create a Plumber API to predict with a deployable `vetiver_model()` object

**\[deprecated\]**

This function was deprecated to use
[vetiver_api](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
directly instead.

## Usage

``` r
vetiver_pr_predict(
  pr,
  vetiver_model,
  path = "/predict",
  debug = is_interactive(),
  ...
)
```

## Arguments

- pr:

  A Plumber router, such as from
  [`plumber::pr()`](https://www.rplumber.io/reference/pr.html).

- vetiver_model:

  A deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  object

- path:

  The endpoint path

- debug:

  `TRUE` provides more insight into your API errors.

- ...:

  Other arguments passed to
  [`predict()`](https://rdrr.io/r/stats/predict.html), such as
  prediction `type`
