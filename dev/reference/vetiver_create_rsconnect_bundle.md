# Create an Posit Connect bundle for a vetiver model API

Use `vetiver_create_rsconnect_bundle()` to create a [Posit
Connect](https://docs.posit.co/connect/) model API bundle for a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
that has been versioned and stored via
[`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_write.md).

## Usage

``` r
vetiver_create_rsconnect_bundle(
  board,
  name,
  version = NULL,
  predict_args = list(),
  filename = fs::file_temp(pattern = "bundle", ext = ".tar.gz"),
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

- filename:

  The path for the model API bundle to be created (can be used as the
  argument to `connectapi::bundle_path()`)

- additional_pkgs:

  Any additional R packages that need to be **attached** via
  [`library()`](https://rdrr.io/r/base/library.html) to run your API, as
  a character vector.

## Value

The location of the model API bundle `filename`, invisibly.

## Details

This function creates a deployable bundle. See [Posit Connect
docs](https://docs.posit.co/connect/cookbook/deploying/) for how to
deploy this bundle, as well as the
[connectapi](https://pkgs.rstudio.com/connectapi/) R package for how to
integrate with Connect's API from R.

The two functions `vetiver_create_rsconnect_bundle()` and
[`vetiver_deploy_rsconnect()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_rsconnect.md)
are alternatives to each other, providing different strategies for
deploying a vetiver model API to Posit Connect.

## See also

[`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_plumber.md),
[`vetiver_deploy_rsconnect()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_rsconnect.md)

## Examples

``` r
if (FALSE) { # rlang::is_installed("connectapi") && identical(Sys.getenv("NOT_CRAN"), "true")
library(pins)
b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)

## when you pin to Posit Connect, your pin name will be typically be like:
## "user.name/cars_linear"
vetiver_create_rsconnect_bundle(
    b,
    "cars_linear",
    predict_args = list(debug = TRUE)
)
}
```
