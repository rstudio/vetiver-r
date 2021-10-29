
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vetiver 🏺

<!-- badges: start -->

[![R-CMD-check](https://github.com/tidymodels/vetiver/workflows/R-CMD-check/badge.svg)](https://github.com/tidymodels/vetiver/actions)
[![Codecov test
coverage](https://codecov.io/gh/tidymodels/vetiver/branch/main/graph/badge.svg)](https://app.codecov.io/gh/tidymodels/vetiver?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

> *Vetiver, the oil of tranquility, is used as a stabilizing ingredient
> in perfumery to preserve more volatile fragrances.*

The goal of vetiver is to provide fluent tooling to version, share,
deploy, and monitor a trained model. Functions handle both recording and
checking the model’s input data prototype, and predicting from a remote
API endpoint. The vetiver package is extensible, with generics that can
support many kinds of models.

## Installation

You can install the released version of vetiver from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("vetiver")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tidymodels/vetiver")
```

## Example

A `vetiver_model()` object collects the information needed to store,
version, and deploy a trained model.

``` r
library(vetiver)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
v
#> 
#> ── cars_linear ─ <butchered_lm> model for deployment 
#> An OLS linear regression model using 10 features
```

You can **version** and **share** your `vetiver_model()` by choosing a
[pins](https://pins.rstudio.com) “board” for it, including a local
folder, RStudio Connect, Amazon S3, and more.

``` r
library(pins)
model_board <- board_temp()
model_board %>% vetiver_pin_write(v)
#> Creating new version '20211029T212859Z-522c5'
#> Writing to pin 'cars_linear'
```

You can **deploy** your pinned `vetiver_model()` via a [Plumber
API](https://www.rplumber.io/), which can be [hosted in a variety of
ways](https://www.rplumber.io/articles/hosting.html).

``` r
library(plumber)
pr() %>%
  vetiver_pr_predict(v) %>%
  pr_run(port = 8088)
```

If the deployed model endpoint is running via one R process (either
remotely on a server or locally, perhaps via a [background job in the
RStudio IDE](https://solutions.rstudio.com/r/jobs/)), you can make
predictions with that deployed model and new data in another, separate R
process.

``` r
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
predict(endpoint, mtcars[4:7, -1])
#> # A tibble: 4 x 1
#>   .pred
#>   <dbl>
#> 1  21.2
#> 2  17.7
#> 3  20.4
#> 4  14.4
```

## Contributing

This project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

-   For questions and discussions about modeling packages, modeling, and
    machine learning, please [post on RStudio
    Community](https://community.rstudio.com/new-topic?category_id=15&tags=tidymodels,question).

-   If you think you have encountered a bug, please [submit an
    issue](https://github.com/tidymodels/vetiver/issues).

-   Either way, learn how to create and share a
    [reprex](https://reprex.tidyverse.org/articles/articles/learn-reprex.html)
    (a minimal, reproducible example), to clearly communicate about your
    code.
