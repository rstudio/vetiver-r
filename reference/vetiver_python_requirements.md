# Use extra files required for deployment

Create files required for deploying an app generated via
[`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_plumber.md),
such as a Python `requirements.txt` or an `.Renviron`

## Usage

``` r
# S3 method for class 'keras.engine.training.Model'
vetiver_python_requirements(model)

# S3 method for class 'luz_module_fitted'
vetiver_renviron_requirements(model)

vetiver_python_requirements(model)

# Default S3 method
vetiver_python_requirements(model)

vetiver_renviron_requirements(model)

# Default S3 method
vetiver_renviron_requirements(model)
```

## Arguments

- model:

  A trained model, such as an [`lm()`](https://rdrr.io/r/stats/lm.html)
  model or a tidymodels
  [`workflows::workflow()`](https://workflows.tidymodels.org/reference/workflow.html).
