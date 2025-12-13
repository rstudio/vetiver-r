# Deploy a vetiver model API to Posit Connect

Use `vetiver_deploy_rsconnect()` to deploy a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
that has been versioned and stored via
[`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_write.md)
as a Plumber API on [Posit Connect](https://docs.posit.co/connect/).

## Usage

``` r
vetiver_deploy_rsconnect(
  board,
  name,
  version = NULL,
  predict_args = list(),
  appTitle = glue::glue("{name} model API"),
  ...,
  additional_pkgs = character(0)
)
```

## Arguments

- board:

  A pin board, created by
  [`board_folder()`](https://pins.rstudio.com/reference/board_folder.html),
  [`board_connect()`](https://pins.rstudio.com/reference/board_connect.html),
  [`board_url()`](https://pins.rstudio.com/reference/board_url.html) or
  another `board_` function.

- name:

  Pin name.

- version:

  Retrieve a specific version of a pin. Use
  [`pin_versions()`](https://pins.rstudio.com/reference/pin_versions.html)
  to find out which versions are available and when they were created.

- predict_args:

  A list of optional arguments passed to
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md)
  such as the prediction `type`.

- appTitle:

  The API title on Posit Connect. Use the default based on `name`, or
  pass in your own title.

- ...:

  Other arguments passed to
  [`rsconnect::deployApp()`](https://rstudio.github.io/rsconnect/reference/deployApp.html)
  such as `appName`, `account`, or `launch.browser`.

- additional_pkgs:

  Any additional R packages that need to be **attached** via
  [`library()`](https://rdrr.io/r/base/library.html) to run your API, as
  a character vector.

## Value

The deployment success (`TRUE` or `FALSE`), invisibly.

## Details

The two functions `vetiver_deploy_rsconnect()` and
[`vetiver_create_rsconnect_bundle()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_rsconnect_bundle.md)
are alternatives to each other, providing different strategies for
deploying a vetiver model API to Posit Connect.

When you first deploy to Connect, your API will only be accessible to
you. You can [change the access
settings](https://docs.posit.co/connect/user/content-settings/#set-viewers)
so others can also access the API. For all access settings other than
"Anyone - no login required", anyone querying your API (including you)
will need to pass authentication details with your API call, [as shown
in the Connect
documentation](https://docs.posit.co/connect/user/vetiver/#predict-from-your-model-endpoint).

## See also

[`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_plumber.md),
[`vetiver_create_rsconnect_bundle()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_rsconnect_bundle.md)

## Examples

``` r
library(pins)
b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)
#> Creating new version '20251213T204124Z-53cb5'
#> Writing to pin 'cars_linear'
#> 
#> Create a Model Card for your published model
#> • Model Cards provide a framework for transparent, responsible reporting
#> • Use the vetiver `.Rmd` template as a place to start
#> This message is displayed once per session.

if (FALSE) {
## pass args for predicting:
vetiver_deploy_rsconnect(
    b,
    "user.name/cars_linear",
    predict_args = list(debug = TRUE)
)

## specify an account name through `...`:
vetiver_deploy_rsconnect(
    b,
    "user.name/cars_linear",
    account = "user.name"
)
}
```
