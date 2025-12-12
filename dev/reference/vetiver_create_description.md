# Model constructor methods

These are developer-facing functions, useful for supporting new model
types. Each model supported by
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
uses up to four methods when the deployable object is created:

- The `vetiver_create_description()` function generates a helpful
  description of the model based on its characteristics. This method is
  required.

- The
  [`vetiver_create_meta()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_meta.md)
  function creates the correct
  [`vetiver_meta()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_meta.md)
  for the model. This is especially helpful for specifying which
  packages are needed for prediction. A model can use the default method
  here, which is to have no special metadata.

- The
  [`vetiver_ptype()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_ptype.md)
  function finds an input data prototype from the training data (a
  zero-row slice) to use for checking at prediction time. This method is
  required.

- The `vetiver_prepare_model()` function executes last. Use this
  function for tasks like checking if the model is trained and reducing
  the size of the model via
  [`butcher::butcher()`](https://butcher.tidymodels.org/reference/butcher.html).
  A model can use the default method here, which is to return the model
  without changes.

## Usage

``` r
# S3 method for class 'train'
vetiver_create_description(model)

# S3 method for class 'train'
vetiver_prepare_model(model)

# S3 method for class 'gam'
vetiver_create_description(model)

# S3 method for class 'gam'
vetiver_prepare_model(model)

# S3 method for class 'glm'
vetiver_create_description(model)

# S3 method for class 'glm'
vetiver_prepare_model(model)

# S3 method for class 'keras.engine.training.Model'
vetiver_create_description(model)

# S3 method for class 'keras.engine.training.Model'
vetiver_prepare_model(model)

# S3 method for class 'kproto'
vetiver_create_description(model)

# S3 method for class 'kproto'
vetiver_prepare_model(model)

# S3 method for class 'lm'
vetiver_create_description(model)

# S3 method for class 'lm'
vetiver_prepare_model(model)

# S3 method for class 'luz_module_fitted'
vetiver_create_description(model)

# S3 method for class 'luz_module_fitted'
vetiver_prepare_model(model)

# S3 method for class 'Learner'
vetiver_create_description(model)

# S3 method for class 'Learner'
vetiver_prepare_model(model)

vetiver_create_description(model)

# Default S3 method
vetiver_create_description(model)

vetiver_prepare_model(model)

# Default S3 method
vetiver_prepare_model(model)

# S3 method for class 'int_conformal_split'
vetiver_create_description(model)

# S3 method for class 'int_conformal_split'
vetiver_prepare_model(model)

# S3 method for class 'int_conformal_full'
vetiver_create_description(model)

# S3 method for class 'int_conformal_full'
vetiver_prepare_model(model)

# S3 method for class 'int_conformal_quantile'
vetiver_create_description(model)

# S3 method for class 'int_conformal_quantile'
vetiver_prepare_model(model)

# S3 method for class 'int_conformal_cv'
vetiver_create_description(model)

# S3 method for class 'int_conformal_cv'
vetiver_prepare_model(model)

# S3 method for class 'ranger'
vetiver_create_description(model)

# S3 method for class 'ranger'
vetiver_prepare_model(model)

# S3 method for class 'recipe'
vetiver_create_description(model)

# S3 method for class 'recipe'
vetiver_prepare_model(model)

# S3 method for class 'model_stack'
vetiver_create_description(model)

# S3 method for class 'model_stack'
vetiver_prepare_model(model)

# S3 method for class 'workflow'
vetiver_create_description(model)

# S3 method for class 'workflow'
vetiver_prepare_model(model)

# S3 method for class 'xgb.Booster'
vetiver_create_description(model)

# S3 method for class 'xgb.Booster'
vetiver_prepare_model(model)
```

## Arguments

- model:

  A trained model, such as an [`lm()`](https://rdrr.io/r/stats/lm.html)
  model or a tidymodels
  [`workflows::workflow()`](https://workflows.tidymodels.org/reference/workflow.html).

## Details

These are four generics that use the class of `model` for dispatch.

## Examples

``` r
cars_lm <- lm(mpg ~ ., data = mtcars)
vetiver_create_description(cars_lm)
#> [1] "An OLS linear regression model"
vetiver_prepare_model(cars_lm)
#> 
#> Call:
#> dummy_call()
#> 
#> Coefficients:
#> (Intercept)          cyl         disp           hp         drat  
#>    12.30337     -0.11144      0.01334     -0.02148      0.78711  
#>          wt         qsec           vs           am         gear  
#>    -3.71530      0.82104      0.31776      2.52023      0.65541  
#>        carb  
#>    -0.19942  
#> 
```
