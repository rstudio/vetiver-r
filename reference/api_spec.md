# Update the OpenAPI specification using model metadata

Update the OpenAPI specification using model metadata

## Usage

``` r
api_spec(spec, vetiver_model, path, all_docs = TRUE)

glue_spec_summary(prototype, return_type)

# Default S3 method
glue_spec_summary(prototype, return_type = NULL)

# S3 method for class 'data.frame'
glue_spec_summary(prototype, return_type = "predictions")

# S3 method for class 'array'
glue_spec_summary(prototype, return_type = "predictions")
```

## Arguments

- spec:

  An OpenAPI Specification formatted list object

- vetiver_model:

  A deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  object

- path:

  The endpoint path

- all_docs:

  Should the interactive visual API documentation be created for *all*
  POST endpoints in the router `pr`? This defaults to `TRUE`, and
  assumes that all POST endpoints use the
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  input data prototype.

- prototype:

  An input data prototype from a model

- return_type:

  Character string to describe what endpoint returns, such as
  "predictions"

## Value

`api_spec()` returns the updated OpenAPI Specification object. This
function uses `glue_spec_summary()` internally, which returns a `glue`
character string.

## Examples

``` r
library(plumber)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
#> Registered S3 method overwritten by 'butcher':
#>   method                 from    
#>   as.character.dev_topic generics

glue_spec_summary(v$prototype)
#> Return predictions from model using 10 features

modify_spec <- function(spec) api_spec(spec, v, "/predict")
pr() |> pr_set_api_spec(api = modify_spec)
#> # Plumber router with 0 endpoints, 4 filters, and 0 sub-routers.
#> # Use `pr_run()` on this object to start the API.
#> ├──[queryString]
#> ├──[body]
#> ├──[cookieParser]
#> ├──[sharedSecret]
```
