# Model handler functions for API endpoint

These are developer-facing functions, useful for supporting new model
types. Each model supported by
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
uses two handler functions in
[`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md):

- The `handler_startup` function executes when the API starts. Use this
  function for tasks like loading packages. A model can use the default
  method here, which is `NULL` (to do nothing at startup).

- The `handler_predict` function executes at each API call. Use this
  function for calling
  [`predict()`](https://rdrr.io/r/stats/predict.html) and any other
  tasks that must be executed at each API call.

## Usage

``` r
# S3 method for class 'train'
handler_startup(vetiver_model)

# S3 method for class 'train'
handler_predict(vetiver_model, ...)

# S3 method for class 'gam'
handler_startup(vetiver_model)

# S3 method for class 'gam'
handler_predict(vetiver_model, ...)

# S3 method for class 'glm'
handler_predict(vetiver_model, ...)

handler_startup(vetiver_model)

# Default S3 method
handler_startup(vetiver_model)

handler_predict(vetiver_model, ...)

# Default S3 method
handler_predict(vetiver_model, ...)

# S3 method for class 'keras.engine.training.Model'
handler_startup(vetiver_model)

# S3 method for class 'keras.engine.training.Model'
handler_predict(vetiver_model, ...)

# S3 method for class 'kproto'
handler_predict(vetiver_model, ...)

# S3 method for class 'lm'
handler_predict(vetiver_model, ...)

# S3 method for class 'luz_module_fitted'
handler_startup(vetiver_model)

# S3 method for class 'luz_module_fitted'
handler_predict(vetiver_model, ...)

# S3 method for class 'Learner'
handler_startup(vetiver_model)

# S3 method for class 'Learner'
handler_predict(vetiver_model, ...)

# S3 method for class 'int_conformal_split'
handler_startup(vetiver_model)

# S3 method for class 'int_conformal_split'
handler_predict(vetiver_model, ...)

# S3 method for class 'int_conformal_full'
handler_startup(vetiver_model)

# S3 method for class 'int_conformal_full'
handler_predict(vetiver_model, ...)

# S3 method for class 'int_conformal_quantile'
handler_startup(vetiver_model)

# S3 method for class 'int_conformal_quantile'
handler_predict(vetiver_model, ...)

# S3 method for class 'int_conformal_cv'
handler_startup(vetiver_model)

# S3 method for class 'int_conformal_cv'
handler_predict(vetiver_model, ...)

# S3 method for class 'ranger'
handler_startup(vetiver_model)

# S3 method for class 'ranger'
handler_predict(vetiver_model, ...)

# S3 method for class 'recipe'
handler_startup(vetiver_model)

# S3 method for class 'recipe'
handler_predict(vetiver_model, ...)

# S3 method for class 'model_stack'
handler_startup(vetiver_model)

# S3 method for class 'model_stack'
handler_predict(vetiver_model, ...)

# S3 method for class 'workflow'
handler_startup(vetiver_model)

# S3 method for class 'workflow'
handler_predict(vetiver_model, ...)

# S3 method for class 'xgb.Booster'
handler_startup(vetiver_model)

# S3 method for class 'xgb.Booster'
handler_predict(vetiver_model, ...)
```

## Arguments

- vetiver_model:

  A deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
  object

- ...:

  Other arguments passed to
  [`predict()`](https://rdrr.io/r/stats/predict.html), such as
  prediction `type`

## Value

A `handler_startup` function should return invisibly, while a
`handler_predict` function should return a function with the signature
`function(req)`. The request body (`req$body`) consists of the new data
at prediction time; this function should return predictions either as a
tibble or as a list coercable to a tibble via
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html).

## Details

These are two generics that use the class of `vetiver_model$model` for
dispatch.

## Examples

``` r
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
handler_startup(v)
handler_predict(v)
#> function (req) 
#> {
#>     newdata <- req$body
#>     if (!is_null(ptype)) {
#>         newdata <- vetiver_type_convert(newdata, ptype)
#>         newdata <- hardhat::scream(newdata, ptype)
#>     }
#>     ret <- predict(vetiver_model$model, newdata = newdata, ...)
#>     list(.pred = ret)
#> }
#> <bytecode: 0x55c2675fde80>
#> <environment: 0x55c2675f6720>
```
