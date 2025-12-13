# Create a Plumber API to predict with a deployable `vetiver_model()` object

Use `vetiver_api()` to add a POST endpoint for predictions from a
trained
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
to a Plumber router.

## Usage

``` r
vetiver_api(
  pr,
  vetiver_model,
  path = "/predict",
  debug = is_interactive(),
  ...
)

vetiver_pr_post(
  pr,
  vetiver_model,
  path = "/predict",
  debug = is_interactive(),
  ...,
  check_prototype = TRUE,
  check_ptype = deprecated()
)

vetiver_pr_docs(pr, vetiver_model, path = "/predict", all_docs = TRUE)
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

- check_prototype:

  Should the input data prototype stored in `vetiver_model` (used for
  visual API documentation) also be used to check new data at prediction
  time? Defaults to `TRUE`.

- check_ptype:

  **\[deprecated\]**

- all_docs:

  Should the interactive visual API documentation be created for *all*
  POST endpoints in the router `pr`? This defaults to `TRUE`, and
  assumes that all POST endpoints use the
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  input data prototype.

## Value

A Plumber router with the prediction endpoint added.

## Details

You can first store and version your
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
with
[`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md),
and then create an API endpoint with `vetiver_api()`.

Setting `debug = TRUE` may expose any sensitive data from your model in
API errors.

Several GET endpoints will also be added to the router `pr`, depending
on the characteristics of the model object:

- a `/pin-url` endpoint to return the URL of the pinned model

- a `/metadata` endpoint to return any metadata stored with the model

- a `/ping` endpoint for the API health

- a `/prototype` endpoint for the model's input data prototype (use
  [`cereal::cereal_from_json()`](https://r-lib.github.io/cereal/reference/cereal_to_json.html))
  to convert this back to a [vctrs
  ptype](https://vctrs.r-lib.org/articles/type-size.html)

The function `vetiver_api()` uses:

- `vetiver_pr_post()` for endpoint definition and

- `vetiver_pr_docs()` to create visual API documentation

These modular functions are available for more advanced use cases.

## Examples

``` r
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")

library(plumber)
pr() |> vetiver_api(v)
#> # Plumber router with 4 endpoints, 4 filters, and 1 sub-router.
#> # Use `pr_run()` on this object to start the API.
#> ├──[queryString]
#> ├──[body]
#> ├──[cookieParser]
#> ├──[sharedSecret]
#> ├──/logo
#> │  │ # Plumber static router serving from directory: /home/runner/work/_temp/Library/vetiver
#> ├──/metadata (GET)
#> ├──/ping (GET)
#> ├──/predict (POST)
#> └──/prototype (GET)
#> 
## is the same as:
pr() |> vetiver_pr_post(v) |> vetiver_pr_docs(v)
#> # Plumber router with 4 endpoints, 4 filters, and 1 sub-router.
#> # Use `pr_run()` on this object to start the API.
#> ├──[queryString]
#> ├──[body]
#> ├──[cookieParser]
#> ├──[sharedSecret]
#> ├──/logo
#> │  │ # Plumber static router serving from directory: /home/runner/work/_temp/Library/vetiver
#> ├──/metadata (GET)
#> ├──/ping (GET)
#> ├──/predict (POST)
#> └──/prototype (GET)
#> 
## for either, next, pipe to `pr_run()`
```
