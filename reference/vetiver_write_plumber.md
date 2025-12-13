# Write a deployable Plumber file for a vetiver model

Use `vetiver_write_plumber()` to create a `plumber.R` file for a
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
that has been versioned and stored via
[`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md).

## Usage

``` r
vetiver_write_plumber(
  board,
  name,
  version = NULL,
  ...,
  file = "plumber.R",
  rsconnect = TRUE,
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

- ...:

  Other arguments passed to
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  such as the endpoint `path` or prediction `type`.

- file:

  A path to write the Plumber file. Defaults to `plumber.R` in the
  working directory. See
  [`plumber::plumb()`](https://www.rplumber.io/reference/plumb.html) for
  naming precedence rules.

- rsconnect:

  Create a Plumber file with features needed for [Posit
  Connect](https://posit.co/products/enterprise/connect/)? Defaults to
  `TRUE`.

- additional_pkgs:

  Any additional R packages that need to be **attached** via
  [`library()`](https://rdrr.io/r/base/library.html) to run your API, as
  a character vector.

## Value

The content of the `plumber.R` file, invisibly.

## Details

By default, this function will find and use the latest version of your
vetiver model; the model API (when deployed) will be linked to that
specific version. You can override this default behavior by choosing a
specific `version`.

## Examples

``` r
library(pins)
tmp <- tempfile()
b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)
#> Creating new version '20251213T203909Z-53cb5'
#> Writing to pin 'cars_linear'

vetiver_write_plumber(b, "cars_linear", file = tmp)
```
