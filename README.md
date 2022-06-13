
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vetiver <a href='https://rstudio.github.io/vetiver-r/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/rstudio/vetiver-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rstudio/vetiver-r/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/vetiver)](https://CRAN.R-project.org/package=vetiver)
[![Codecov test
coverage](https://codecov.io/gh/rstudio/vetiver-r/branch/main/graph/badge.svg)](https://app.codecov.io/gh/rstudio/vetiver-r?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

> *Vetiver, the oil of tranquility, is used as a stabilizing ingredient
> in perfumery to preserve more volatile fragrances.*

The goal of vetiver is to provide fluent tooling to version, share,
deploy, and monitor a trained model. Functions handle both recording and
checking the model’s input data prototype, and predicting from a remote
API endpoint. The vetiver package is extensible, with generics that can
support many kinds of models, and available for both R and Python. To
learn more about vetiver, see:

-   the documentation at <https://vetiver.rstudio.com/>
-   the Python package at <https://rstudio.github.io/vetiver-python/>

You can use vetiver with:

-   a [tidymodels](https://www.tidymodels.org/) workflow
-   [caret](https://topepo.github.io/caret/)
-   [mlr3](https://mlr3.mlr-org.com/)
-   [XGBoost](https://xgboost.readthedocs.io/en/latest/R-package/)
-   [ranger](https://cran.r-project.org/package=ranger)
-   [`lm()`](https://stat.ethz.ch/R-manual/R-patched/library/stats/html/lm.html)
    and
    [`glm()`](https://stat.ethz.ch/R-manual/R-patched/library/stats/html/glm.html)

## Installation

You can install the released version of vetiver from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("vetiver")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rstudio/vetiver-r")
```

## Example

A `vetiver_model()` object collects the information needed to store,
version, and deploy a trained model.

``` r
library(parsnip)
library(workflows)
data(Sacramento, package = "modeldata")

rf_spec <- rand_forest(mode = "regression")
rf_form <- price ~ type + sqft + beds + baths

rf_fit <- 
    workflow(rf_form, rf_spec) %>%
    fit(Sacramento)

library(vetiver)
v <- vetiver_model(rf_fit, "sacramento_rf")
v
#> 
#> ── sacramento_rf ─ <butchered_workflow> model for deployment 
#> A ranger regression modeling workflow using 4 features
```

You can **version** and **share** your `vetiver_model()` by choosing a
[pins](https://pins.rstudio.com) “board” for it, including a local
folder, RStudio Connect, Amazon S3, and more.

``` r
library(pins)
model_board <- board_temp()
model_board %>% vetiver_pin_write(v)
```

You can **deploy** your pinned `vetiver_model()` via a [Plumber
API](https://www.rplumber.io/), which can be [hosted in a variety of
ways](https://www.rplumber.io/articles/hosting.html).

``` r
library(plumber)
pr() %>%
  vetiver_api(v) %>%
  pr_run(port = 8088)
```

If the deployed model endpoint is running via one R process (either
remotely on a server or locally, perhaps via a [background job in the
RStudio IDE](https://solutions.rstudio.com/r/jobs/)), you can make
predictions with that deployed model and new data in another, separate R
process. First, create a model endpoint:

``` r
library(vetiver)
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint
#> 
#> ── A model API endpoint for prediction: 
#> http://127.0.0.1:8088/predict
```

Such a model API endpoint deployed with vetiver will return predictions
for appropriate new data.

``` r
library(tidyverse)
new_sac <- Sacramento %>% 
    slice_sample(n = 20) %>% 
    select(type, sqft, beds, baths)

predict(endpoint, new_sac)
#> # A tibble: 20 x 1
#>      .pred
#>      <dbl>
#>  1 165042.
#>  2 212461.
#>  3 119008.
#>  4 201752.
#>  5 223096.
#>  6 115696.
#>  7 191262.
#>  8 211706.
#>  9 259336.
#> 10 206826.
#> 11 234952.
#> 12 221993.
#> 13 204983.
#> 14 548052.
#> 15 151186.
#> 16 299365.
#> 17 213439.
#> 18 287993.
#> 19 272017.
#> 20 226629.
```

## Contributing

This project is released with a [Contributor Code of
Conduct](https://www.contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

-   For questions and discussions about modeling packages, modeling, and
    machine learning, please [post on RStudio
    Community](https://community.rstudio.com/new-topic?category_id=15&tags=tidymodels,question).

-   If you think you have encountered a bug, please [submit an
    issue](https://github.com/rstudio/vetiver-r/issues).

-   Either way, learn how to create and share a
    [reprex](https://reprex.tidyverse.org/articles/articles/learn-reprex.html)
    (a minimal, reproducible example), to clearly communicate about your
    code.
