# Create a vetiver input data prototype

Optionally find and return an input data prototype for a model.

## Usage

``` r
# S3 method for class 'train'
vetiver_ptype(model, ...)

# S3 method for class 'gam'
vetiver_ptype(model, ...)

# S3 method for class 'glm'
vetiver_ptype(model, ...)

# S3 method for class 'keras.engine.training.Model'
vetiver_ptype(model, ...)

# S3 method for class 'kproto'
vetiver_ptype(model, ...)

# S3 method for class 'lm'
vetiver_ptype(model, ...)

# S3 method for class 'luz_module_fitted'
vetiver_ptype(model, ...)

# S3 method for class 'Learner'
vetiver_ptype(model, ...)

# S3 method for class 'int_conformal_split'
vetiver_ptype(model, ...)

# S3 method for class 'int_conformal_full'
vetiver_ptype(model, ...)

# S3 method for class 'int_conformal_quantile'
vetiver_ptype(model, ...)

# S3 method for class 'int_conformal_cv'
vetiver_ptype(model, ...)

vetiver_ptype(model, ...)

# Default S3 method
vetiver_ptype(model, ...)

vetiver_create_ptype(model, save_prototype, ...)

# S3 method for class 'ranger'
vetiver_ptype(model, ...)

# S3 method for class 'recipe'
vetiver_ptype(model, ...)

# S3 method for class 'model_stack'
vetiver_ptype(model, ...)

# S3 method for class 'workflow'
vetiver_ptype(model, ...)

# S3 method for class 'xgb.Booster'
vetiver_ptype(model, ...)
```

## Arguments

- model:

  A trained model, such as an [`lm()`](https://rdrr.io/r/stats/lm.html)
  model or a tidymodels
  [`workflows::workflow()`](https://workflows.tidymodels.org/reference/workflow.html).

- ...:

  Other method-specific arguments passed to `vetiver_ptype()` to compute
  an input data prototype, such as `prototype_data` (a sample of
  training features).

- save_prototype:

  Should an input data prototype be stored with the model? The options
  are `TRUE` (the default, which stores a zero-row slice of the training
  data), `FALSE` (no input data prototype for visual documentation or
  checking), or a dataframe to be used for both checking at prediction
  time *and* examples in API visual documentation.

## Value

A `vetiver_ptype` method returns a zero-row dataframe, and
`vetiver_create_ptype()` returns either such a zero-row dataframe,
`NULL`, or the dataframe passed to `save_prototype`.

## Details

These are developer-facing functions, useful for supporting new model
types. A
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
object optionally stores an input data prototype for checking at
prediction time.

- The default for `save_prototype`, `TRUE`, finds an input data
  prototype (a zero-row slice of the training data) via
  `vetiver_ptype()`.

- `save_prototype = FALSE` opts out of storing any input data prototype.

- You may pass your own data to `save_prototype`, but be sure to check
  that it has the same structure as your training data, perhaps with
  [`hardhat::scream()`](https://hardhat.tidymodels.org/reference/scream.html).

## Examples

``` r
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)

vetiver_create_ptype(cars_lm, TRUE)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: cyl <dbl>, disp <dbl>

## calls the right method for `model` via:
vetiver_ptype(cars_lm)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: cyl <dbl>, disp <dbl>

## can also turn off prototype
vetiver_create_ptype(cars_lm, FALSE)
#> NULL
## some models require that you pass in training features
cars_rf <- ranger::ranger(mpg ~ ., data = mtcars)
vetiver_ptype(cars_rf, prototype_data = mtcars[,-1])
#> # A tibble: 0 × 10
#> # ℹ 10 variables: cyl <dbl>, disp <dbl>, hp <dbl>, drat <dbl>,
#> #   wt <dbl>, qsec <dbl>, vs <dbl>, am <dbl>, gear <dbl>, carb <dbl>
```
