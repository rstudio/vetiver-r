# Convert new data at prediction time using input data prototype

This is a developer-facing function, useful for supporting new model
types. At prediction time, new observations typically must be checked
and sometimes converted to the data types from training time.

## Usage

``` r
vetiver_type_convert(new_data, ptype)
```

## Arguments

- new_data:

  New data for making predictions, such as a data frame.

- ptype:

  An input data prototype, such as a 0-row slice of the training data

## Value

A converted dataframe

## Examples

``` r
library(tibble)
training_df <- tibble(x = as.Date("2021-01-01") + 0:9,
                      y = LETTERS[1:10], z = letters[11:20])
training_df
#> # A tibble: 10 × 3
#>    x          y     z    
#>    <date>     <chr> <chr>
#>  1 2021-01-01 A     k    
#>  2 2021-01-02 B     l    
#>  3 2021-01-03 C     m    
#>  4 2021-01-04 D     n    
#>  5 2021-01-05 E     o    
#>  6 2021-01-06 F     p    
#>  7 2021-01-07 G     q    
#>  8 2021-01-08 H     r    
#>  9 2021-01-09 I     s    
#> 10 2021-01-10 J     t    

prototype <- vctrs::vec_slice(training_df, 0)
vetiver_type_convert(tibble(x = "2021-02-01", y = "J", z = "k"), prototype)
#> # A tibble: 1 × 3
#>   x          y     z    
#>   <date>     <chr> <chr>
#> 1 2021-02-01 J     k    

## unsuccessful conversion generates an error:
try(vetiver_type_convert(tibble(x = "potato", y = "J", z = "k"), prototype))
#> Error in vetiver_type_convert(tibble(x = "potato", y = "J", z = "k"),  : 
#>   [0, 1]: expected date like , but got 'potato'

## error for missing column:
try(vetiver_type_convert(tibble(x = "potato", y = "J"), prototype))
#> Error in hardhat::validate_column_names(new_data, colnames(ptype)) : 
#>   The required column "z" is missing.
```
