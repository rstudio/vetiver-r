# Version, share, and deploy a model with vetiver

The goal of vetiver is to provide fluent tooling for MLOps tasks for
your trained model including:

- versioning
- storing
- sharing
- deploying

For more extensive documentation, visit <https://vetiver.posit.co/>.

## Create a `vetiver_model()`

The vetiver package is extensible, with generics that can support many
kinds of models. For this example, let’s consider one kind of model
supported by vetiver, a [tidymodels](https://www.tidymodels.org/)
workflow that encompasses both feature engineering and model estimation.

``` r
library(parsnip)
library(recipes)
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> 
#> Attaching package: 'recipes'
#> The following object is masked from 'package:stats':
#> 
#>     step
library(workflows)
data(bivariate, package = "modeldata")
bivariate_train
#> # A tibble: 1,009 × 3
#>        A     B Class
#>    <dbl> <dbl> <fct>
#>  1 3279. 155.  One  
#>  2 1727.  84.6 Two  
#>  3 1195. 101.  One  
#>  4 1027.  68.7 Two  
#>  5 1036.  73.4 One  
#>  6 1434.  79.5 One  
#>  7  633.  67.4 One  
#>  8 1262.  67.0 Two  
#>  9  985.  62.0 Two  
#> 10  893.  56.8 Two  
#> # ℹ 999 more rows

biv_rec <-
  recipe(Class ~ ., data = bivariate_train) |>
  step_BoxCox(all_predictors())|>
  step_normalize(all_predictors())

svm_spec <-
  svm_linear(mode = "classification") |>
  set_engine("LiblineaR")

svm_fit <- 
  workflow(biv_rec, svm_spec) |>
  fit(sample_frac(bivariate_train, 0.7))
```

This `svm_fit` object is a fitted workflow, with both feature
engineering and model parameters estimated using the training data
`bivariate_train`. We can create a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
from this trained model; a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
collects the information needed to store, version, and deploy a trained
model.

``` r
library(vetiver)
v <- vetiver_model(svm_fit, "biv_svm")
#> Registered S3 method overwritten by 'butcher':
#>   method                 from    
#>   as.character.dev_topic generics
v
#> 
#> ── biv_svm ─ <bundled_workflow> model for deployment 
#> A LiblineaR classification modeling workflow using 2 features
```

Think of this
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
as a deployable model object.

## Store and version your model

You can store and version your model by choosing a
[pins](https://pins.rstudio.com) “board” for it, including a local
folder, Posit Connect, Amazon S3, and more. Most pins boards have
versioning turned on by default, but we can turn it on explicitly for
our temporary demo board. When we write the
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
to our board, the binary model object is stored on our board together
with necessary metadata, like the packages needed to make a prediction
and the model’s input data prototype for checking new data at prediction
time.

``` r
library(pins)
model_board <- board_temp(versioned = TRUE)
model_board |> vetiver_pin_write(v)
```

Let’s train our model again with a new version of the dataset and write
it once more to our board.

``` r
svm_fit <- 
  workflow(biv_rec, svm_spec) |>
  fit(sample_frac(bivariate_train, 0.7))

v <- vetiver_model(svm_fit, "biv_svm")

model_board |> vetiver_pin_write(v)
```

Both versions are stored, and we have access to both.

``` r
model_board |> pin_versions("biv_svm")
#> # A tibble: 2 × 3
#>   version                created             hash 
#>   <chr>                  <dttm>              <chr>
#> 1 20251212T191557Z-26e95 2025-12-12 19:15:57 26e95
#> 2 20251212T191557Z-f2349 2025-12-12 19:15:57 f2349
```

The primary purpose of pins is to make it easy to share data artifacts,
so depending on the board you choose, your pinned
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
can be shareable with your collaborators.

## Deploy your model

You can deploy your model by creating a
[Plumber](https://www.rplumber.io/) router, and adding a POST endpoint
for making predictions.

``` r
library(plumber)
pr() |>
  vetiver_api(v)
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
```

To start a server using this object, pipe (`|>`) to
`pr_run(port = 8088)` or your port of choice. This allows you to
interact with your vetiver API locally and debug it. Plumber APIs such
as these can be [hosted in a variety of
ways](https://www.rplumber.io/articles/hosting.html). You can use the
function
[`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_plumber.md)
to create a ready-to-go `plumber.R` file that is especially suited for
[Posit Connect](https://posit.co/products/enterprise/connect/).

``` r
vetiver_write_plumber(model_board, "biv_svm")
```

    # Generated by the vetiver package; edit with care

    library(pins)
    library(plumber)
    library(rapidoc)
    library(vetiver)

    # Packages needed to generate model predictions
    if (FALSE) {
        library(LiblineaR)
        library(parsnip)
        library(recipes)
        library(workflows)
    }
    b <- board_folder(path = "/tmp/RtmptMRKXP/pins-3ec720c6db6d")
    v <- vetiver_pin_read(b, "biv_svm", version = "20251212T191557Z-26e95")

    #* @plumber
    function(pr) {
        pr |> vetiver_api(v)
    }

In a real-world situation, you would see something like
`b <- board_connect()` or `b <- board_s3()` here instead of our
temporary demo board. Notice that the deployment is strongly linked to a
*specific version* of the pinned model; if you pin another version of
the model after you deploy your model, your deployed model will not be
affected.

## Predict from your model endpoint

A model deployed via vetiver can be treated as a special
[`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md)
object.

``` r
library(vetiver)
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint
#> 
#> ── A model API endpoint for prediction: 
#> http://127.0.0.1:8088/predict
```

If such a deployed model endpoint is running via one R process (either
remotely on a server or locally, perhaps via a [background job in the
RStudio IDE](https://docs.posit.co/ide/user/ide/guide/tools/jobs.html)),
you can make predictions with that deployed model and new data in
another, separate R process.

``` r
data(bivariate, package = "modeldata")
predict(endpoint, bivariate_test)
#> # A tibble: 710 × 1
#>    .pred_class
#>    <chr>      
#>  1 One        
#>  2 Two        
#>  3 One        
#>  4 Two        
#>  5 Two        
#>  6 One        
#>  7 Two        
#>  8 Two        
#>  9 Two        
#> 10 One        
#> # … with 700 more rows
```

Being able to [`predict()`](https://rdrr.io/r/stats/predict.html) on a
vetiver model endpoint takes advantage of the model’s input data
prototype and other metadata that is stored with the model.
