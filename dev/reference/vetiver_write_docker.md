# Write a Dockerfile for a vetiver model

After creating a Plumber file with
[`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_plumber.md),
use `vetiver_write_docker()` to create a Dockerfile plus a
`vetiver_renv.lock` file for a pinned
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md).

## Usage

``` r
vetiver_write_docker(
  vetiver_model,
  plumber_file = "plumber.R",
  path = ".",
  ...,
  lockfile = "vetiver_renv.lock",
  rspm = TRUE,
  base_image = glue::glue("FROM rocker/r-ver:{getRversion()}"),
  port = 8000,
  expose = TRUE,
  additional_pkgs = character(0)
)
```

## Arguments

- vetiver_model:

  A deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
  object

- plumber_file:

  A path for your Plumber file, created via
  [`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_plumber.md).
  Defaults to `plumber.R` in the working directory.

- path:

  A path to write the Dockerfile and `lockfile`, capturing the model's
  package dependencies. Defaults to the working directory.

- ...:

  Not currently used.

- lockfile:

  The generated lockfile in `path`. Defaults to `"vetiver_renv.lock"`.

- rspm:

  A logical to use the [RStudio Public Package
  Manager](https://packagemanager.rstudio.com/) for
  [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
  in the Docker image. Defaults to `TRUE`.

- base_image:

  The base Docker image to start with. Defaults to `rocker/r-ver` for
  the version of R you are working with, but models like keras will
  require a different base image.

- port:

  The server port for listening: a number such as 8080 or an expression
  like `'as.numeric(Sys.getenv("PORT"))'` when the port is injected as
  an environment variable.

- expose:

  Add `EXPOSE` to the Dockerfile? This is helpful for using Docker
  Desktop but does not work with an expression for `port`.

- additional_pkgs:

  A character vector of additional package names to add to the Docker
  image. For example, some boards like
  [`pins::board_s3()`](https://pins.rstudio.com/reference/board_s3.html)
  require additional software; you can use `required_pkgs(board)` here.

## Value

The content of the Dockerfile, invisibly.

## Examples

``` r
library(pins)
tmp_plumber <- tempfile()
b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")
vetiver_pin_write(b, v)
#> Creating new version '20251213T204131Z-53cb5'
#> Writing to pin 'cars_linear'
vetiver_write_plumber(b, "cars_linear", file = tmp_plumber)

## default port
vetiver_write_docker(v, tmp_plumber, tempdir())
#> The following required packages are not installed:
#> - cpp11  [required by lobstr, readr, tzdb, and 1 other]
#> Consider reinstalling these packages before snapshotting the lockfile.
#> 
#> - The lockfile is already up to date.
## install more pkgs, like those required to access board
vetiver_write_docker(v, tmp_plumber, tempdir(),
                     additional_pkgs = required_pkgs(b))
#> The following required packages are not installed:
#> - cpp11  [required by lobstr, readr, tzdb, and 1 other]
#> Consider reinstalling these packages before snapshotting the lockfile.
#> 
#> - The lockfile is already up to date.
## port from env variable
vetiver_write_docker(v, tmp_plumber, tempdir(),
                     port = 'as.numeric(Sys.getenv("PORT"))',
                     expose = FALSE)
#> The following required packages are not installed:
#> - cpp11  [required by lobstr, readr, tzdb, and 1 other]
#> Consider reinstalling these packages before snapshotting the lockfile.
#> 
#> - The lockfile is already up to date.
```
