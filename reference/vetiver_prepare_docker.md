# Generate files necessary to build a Docker container for a vetiver model

Deploying a vetiver model via Docker requires several files. Use this
function to create these needed files in the directory located at
`path`.

## Usage

``` r
vetiver_prepare_docker(
  board,
  name,
  version = NULL,
  path = ".",
  predict_args = list(),
  docker_args = list()
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

- path:

  A path to write the Plumber file, Dockerfile, and lockfile, capturing
  the model's dependencies.

- predict_args:

  A list of optional arguments passed to
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  such as the prediction `type`.

- docker_args:

  A list of optional arguments passed to
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_docker.md)
  such as the `lockfile` name or whether to use `rspm`. Do not pass
  `additional_pkgs` here, as this function uses
  `additional_pkgs = required_pkgs(board)`.

## Value

An invisible `TRUE`.

## Details

The function `vetiver_prepare_docker()` uses:

- [`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_plumber.md)
  to create a Plumber file and

- [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_docker.md)
  to create a Dockerfile and renv lockfile

These modular functions are available for more advanced use cases. For
models such as keras and torch, you will need to edit the generated
Dockerfile to, for example, `COPY requirements.txt requirements.txt` or
similar.

## Examples

``` r
library(pins)
b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)
#> Creating new version '20251213T203904Z-53cb5'
#> Writing to pin 'cars_linear'

vetiver_prepare_docker(b, "cars_linear", path = tempdir())
#> The following required packages are not installed:
#> - cpp11  [required by lobstr, readr, tzdb, and 1 other]
#> Consider reinstalling these packages before snapshotting the lockfile.
#> 
#> The following package(s) will be updated in the lockfile:
#> 
#> # Local ---------------------------------------------------------------
#> - vetiver       [* -> 0.2.7]
#> 
#> # RSPM ----------------------------------------------------------------
#> - R6            [* -> 2.6.1]
#> - Rcpp          [* -> 1.1.0]
#> - askpass       [* -> 1.2.1]
#> - bit           [* -> 4.6.0]
#> - bit64         [* -> 4.6.0-1]
#> - bundle        [* -> 0.1.3]
#> - butcher       [* -> 0.4.0]
#> - cereal        [* -> 0.1.0]
#> - cli           [* -> 3.6.5]
#> - clipr         [* -> 0.8.0]
#> - crayon        [* -> 1.5.3]
#> - curl          [* -> 7.0.0]
#> - digest        [* -> 0.6.39]
#> - fastmap       [* -> 1.2.0]
#> - fs            [* -> 1.6.6]
#> - generics      [* -> 0.1.4]
#> - glue          [* -> 1.8.0]
#> - hardhat       [* -> 1.4.2]
#> - hms           [* -> 1.1.4]
#> - httpuv        [* -> 1.6.16]
#> - httr          [* -> 1.4.7]
#> - jsonlite      [* -> 2.0.0]
#> - later         [* -> 1.4.4]
#> - lifecycle     [* -> 1.0.4]
#> - lobstr        [* -> 1.1.3]
#> - magrittr      [* -> 2.0.4]
#> - mime          [* -> 0.13]
#> - openssl       [* -> 2.3.4]
#> - otel          [* -> 0.2.0]
#> - pillar        [* -> 1.11.1]
#> - pins          [* -> 1.4.1]
#> - pkgconfig     [* -> 2.0.3]
#> - plumber       [* -> 1.3.0]
#> - prettyunits   [* -> 1.2.0]
#> - progress      [* -> 1.2.3]
#> - promises      [* -> 1.5.0]
#> - purrr         [* -> 1.2.0]
#> - rapidoc       [* -> 9.3.4]
#> - rappdirs      [* -> 0.3.3]
#> - readr         [* -> 2.1.6]
#> - renv          [* -> 1.1.5]
#> - rlang         [* -> 1.1.6]
#> - sodium        [* -> 1.4.0]
#> - sparsevctrs   [* -> 0.3.5]
#> - stringi       [* -> 1.8.7]
#> - swagger       [* -> 5.17.14.1]
#> - sys           [* -> 3.4.3]
#> - tibble        [* -> 3.3.0]
#> - tidyselect    [* -> 1.2.1]
#> - tzdb          [* -> 0.5.0]
#> - utf8          [* -> 1.2.6]
#> - vctrs         [* -> 0.6.5]
#> - vroom         [* -> 1.6.7]
#> - webutils      [* -> 1.2.2]
#> - whisker       [* -> 0.4.1]
#> - withr         [* -> 3.0.2]
#> - yaml          [* -> 2.3.12]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R             [* -> 4.5.2]
#> 
#> - Lockfile written to "vetiver_renv.lock".
```
