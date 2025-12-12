# Identify data types for each column in an input data prototype

The OpenAPI specification of a Plumber API created via
[`plumber::pr()`](https://www.rplumber.io/reference/pr.html) can be
modified via
[`plumber::pr_set_api_spec()`](https://www.rplumber.io/reference/pr_set_api_spec.html),
and this helper function will identify data types of predictors and
create a list to use in this specification. These are *not* R data
types, but instead basic JSON data types. For example, factors in R will
be documented as strings in the OpenAPI specification.

## Usage

``` r
map_request_body(prototype)
```

## Arguments

- prototype:

  An input data prototype from a model

## Value

A list to be used within
[`plumber::pr_set_api_spec()`](https://www.rplumber.io/reference/pr_set_api_spec.html)

## Details

This is a developer-facing function, useful for supporting new model
types. It is called by
[`api_spec()`](https://rstudio.github.io/vetiver-r/dev/reference/api_spec.md).

## Examples

``` r
map_request_body(vctrs::vec_slice(chickwts, 0))
#> $content
#> $content$`application/json`
#> $content$`application/json`$schema
#> $content$`application/json`$schema$type
#> [1] "array"
#> 
#> $content$`application/json`$schema$minItems
#> [1] 1
#> 
#> $content$`application/json`$schema$items
#> $content$`application/json`$schema$items$type
#> [1] "object"
#> 
#> $content$`application/json`$schema$items$properties
#> $content$`application/json`$schema$items$properties$weight
#> $content$`application/json`$schema$items$properties$weight$type
#> [1] "number"
#> 
#> 
#> $content$`application/json`$schema$items$properties$feed
#> $content$`application/json`$schema$items$properties$feed$type
#> [1] "string"
#> 
#> 
#> 
#> 
#> 
#> 
#> 
```
