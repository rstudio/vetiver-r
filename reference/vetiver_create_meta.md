# Metadata constructors for `vetiver_model()` object

These are developer-facing functions, useful for supporting new model
types. The metadata stored in a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
object has four elements:

- `$user`, the metadata supplied by the user

- `$version`, the version of the pin (which can be `NULL` before
  pinning)

- `$url`, the URL where the pin is located, if any

- `$required_pkgs`, a character string of R packages required for
  prediction

## Usage

``` r
# S3 method for class 'train'
vetiver_create_meta(model, metadata)

# S3 method for class 'gam'
vetiver_create_meta(model, metadata)

# S3 method for class 'keras.engine.training.Model'
vetiver_create_meta(model, metadata)

# S3 method for class 'kproto'
vetiver_create_meta(model, metadata)

# S3 method for class 'luz_module_fitted'
vetiver_create_meta(model, metadata)

vetiver_meta(user = list(), version = NULL, url = NULL, required_pkgs = NULL)

vetiver_create_meta(model, metadata)

# Default S3 method
vetiver_create_meta(model, metadata)

# S3 method for class 'Learner'
vetiver_create_meta(model, metadata)

# S3 method for class 'int_conformal_split'
vetiver_create_meta(model, metadata)

# S3 method for class 'int_conformal_full'
vetiver_create_meta(model, metadata)

# S3 method for class 'int_conformal_quantile'
vetiver_create_meta(model, metadata)

# S3 method for class 'int_conformal_cv'
vetiver_create_meta(model, metadata)

# S3 method for class 'ranger'
vetiver_create_meta(model, metadata)

# S3 method for class 'recipe'
vetiver_create_meta(model, metadata)

# S3 method for class 'model_stack'
vetiver_create_meta(model, metadata)

# S3 method for class 'workflow'
vetiver_create_meta(model, metadata)

# S3 method for class 'xgb.Booster'
vetiver_create_meta(model, metadata)
```

## Arguments

- model:

  A trained model, such as an [`lm()`](https://rdrr.io/r/stats/lm.html)
  model or a tidymodels
  [`workflows::workflow()`](https://workflows.tidymodels.org/reference/workflow.html).

- metadata:

  A list containing additional metadata to store with the pin. When
  retrieving the pin, this will be stored in the `user` key, to avoid
  potential clashes with the metadata that pins itself uses.

- user:

  Metadata supplied by the user

- version:

  Version of the pin

- url:

  URL for the pin, if any

- required_pkgs:

  Character string of R packages required for prediction

## Value

The `vetiver_meta()` constructor returns a list. The
`vetiver_create_meta` function returns a `vetiver_meta()` list.

## Examples

``` r
vetiver_meta()
#> $user
#> list()
#> 
#> $version
#> NULL
#> 
#> $url
#> NULL
#> 
#> $required_pkgs
#> NULL
#> 

cars_lm <- lm(mpg ~ ., data = mtcars)
vetiver_create_meta(cars_lm, list())
#> $user
#> list()
#> 
#> $version
#> NULL
#> 
#> $url
#> NULL
#> 
#> $required_pkgs
#> NULL
#> 
```
