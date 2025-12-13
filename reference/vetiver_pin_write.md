# Read and write a trained model to a board of models

Use `vetiver_pin_write()` to pin a trained model to a board of models,
along with an input prototype for new data and other model metadata. Use
`vetiver_pin_read()` to retrieve that pinned object.

## Usage

``` r
vetiver_pin_write(board, vetiver_model, ..., check_renv = FALSE)

vetiver_pin_read(board, name, version = NULL, check_renv = FALSE)
```

## Arguments

- board:

  A pin board, created by
  [`board_folder()`](https://pins.rstudio.com/reference/board_folder.html),
  [`board_connect()`](https://pins.rstudio.com/reference/board_connect.html),
  [`board_url()`](https://pins.rstudio.com/reference/board_url.html) or
  another `board_` function.

- vetiver_model:

  A deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  object

- ...:

  Additional arguments passed on to methods for a specific board.

- check_renv:

  Use [renv](https://rstudio.github.io/renv/) to record the packages
  used at training time with `vetiver_pin_write()` and check for
  differences with `vetiver_pin_read()`. Defaults to `FALSE`.

- name:

  Pin name.

- version:

  Retrieve a specific version of a pin. Use
  [`pin_versions()`](https://pins.rstudio.com/reference/pin_versions.html)
  to find out which versions are available and when they were created.

## Value

`vetiver_pin_read()` returns a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md);
`vetiver_pin_write()` returns the name of the new pin, invisibly.

## Details

These functions read and write a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
pin on the specified `board` containing the model object itself and
other elements needed for prediction, such as the model's input data
prototype or which packages are needed at prediction time. You may use
[`pins::pin_read()`](https://pins.rstudio.com/reference/pin_read.html)
or
[`pins::pin_meta()`](https://pins.rstudio.com/reference/pin_meta.html)
to handle the pin, but `vetiver_pin_read()` returns a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
object ready for deployment.

## Examples

``` r
library(pins)
model_board <- board_temp()

cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(model_board, v)
#> Creating new version '20251213T203902Z-53cb5'
#> Writing to pin 'cars_linear'
model_board
#> Pin board <pins_board_folder>
#> Path: '/tmp/RtmpeUQ6fa/pins-19ae6931d6d4'
#> Cache size: 0

vetiver_pin_read(model_board, "cars_linear")
#> 
#> ── cars_linear ─ <butchered_lm> model for deployment 
#> An OLS linear regression model using 10 features

# can use `version` argument to read a specific version:
pin_versions(model_board, "cars_linear")
#> # A tibble: 1 × 3
#>   version                created             hash 
#>   <chr>                  <dttm>              <chr>
#> 1 20251213T203902Z-53cb5 2025-12-13 20:39:02 53cb5
# can store an renv lockfile as part of the pin:
vetiver_pin_write(model_board, v, check_renv = TRUE)
#> Error in pin_store(board, name, path, meta, versioned = versioned, x = x,     ...): The new version "20251213T203902Z-53cb5" is the same as the
#> most recent version.
#> ℹ Did you try to create a new version with the same timestamp as the
#>   last version?
```
