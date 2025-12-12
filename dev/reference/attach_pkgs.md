# Fully attach or load packages for making model predictions

These are developer-facing functions, useful for supporting new model
types. Some models require one or more R packages to be fully attached
to make predictions, and some require only that the namespace of one or
more R packages is loaded.

## Usage

``` r
attach_pkgs(pkgs)

load_pkgs(pkgs)
```

## Arguments

- pkgs:

  A character vector of package names to load or fully attach.

## Value

An invisible `TRUE`.

## Details

These two functions will attempt either to:

- fully attach or

- load

the namespace of the `pkgs` vector of package names, preserving the
current random seed.

To learn more about load vs. attach, read the ["Dependencies" chapter of
*R
Packages*](https://r-pkgs.org/dependencies-mindset-background.html#sec-dependencies-attach-vs-load).
For deploying a model, it is likely safer to fully attach needed
packages but that comes with the risk of naming conflicts between
packages.

## Examples

``` r
## succeed
load_pkgs(c("knitr", "readr"))
attach_pkgs(c("knitr", "readr"))

## fail
try(load_pkgs(c("bloopy", "readr")))
#> Error in load_pkgs(c("bloopy", "readr")) : 
#>   Namespace(s) could not be loaded:
#> • bloopy
try(attach_pkgs(c("bloopy", "readr")))
#> Error in attach_pkgs(c("bloopy", "readr")) : 
#>   Package(s) could not be attached:
#> • bloopy
```
