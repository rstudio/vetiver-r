# Update model metrics over time for monitoring

These three functions can be used for model monitoring (such as in a
monitoring dashboard):

- [`vetiver_compute_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_compute_metrics.md)
  computes metrics (such as accuracy for a classification model or RMSE
  for a regression model) at a chosen time aggregation `period`

- `vetiver_pin_metrics()` updates an existing pin storing model metrics
  over time

- [`vetiver_plot_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_plot_metrics.md)
  creates a plot of metrics over time

## Usage

``` r
vetiver_pin_metrics(
  board,
  df_metrics,
  metrics_pin_name,
  .index = .index,
  overwrite = FALSE,
  type = NULL,
  ...
)
```

## Arguments

- board:

  A pin board, created by
  [`board_folder()`](https://pins.rstudio.com/reference/board_folder.html),
  [`board_connect()`](https://pins.rstudio.com/reference/board_connect.html),
  [`board_url()`](https://pins.rstudio.com/reference/board_url.html) or
  another `board_` function.

- df_metrics:

  A tidy dataframe of metrics over time, such as created by
  [`vetiver_compute_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_compute_metrics.md).

- metrics_pin_name:

  Pin name for where the *metrics* are stored (as opposed to where the
  model object is stored with
  [`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md)).

- .index:

  The variable in `df_metrics` containing the aggregated dates or
  date-times (from `time_var` in `data`). Defaults to `.index`.

- overwrite:

  If `FALSE` (the default), error when the new metrics contain
  overlapping dates with the existing pin.If `TRUE`, overwrite any
  metrics for dates that exist both in the existing pin and new metrics
  with the *new* values.

- type:

  File type used to save metrics to disk. With the default `NULL`, uses
  the `type` of the existing pin. Options are "rds" and "arrow".

- ...:

  Additional arguments passed on to methods for a specific board.

## Value

A dataframe of metrics.

## Details

Sometimes when you monitor a model at a given time aggregation, you may
end up with dates in your new metrics (like `new_metrics` in the
example) that are the same as dates in your existing aggregated metrics
(like `original_metrics` in the example). This can happen if you need to
re-run a monitoring report because something failed. With
`overwrite = FALSE` (the default), `vetiver_pin_metrics()` will error
when there are overlapping dates. With `overwrite = TRUE`,
`vetiver_pin_metrics()` will replace such metrics with the new values.
You probably want `FALSE` for interactive use and `TRUE` for dashboards
or reports that run on a schedule.

You can initially create your pin with `type = "arrow"` or the default
(`type = "rds"`). `vetiver_pin_metrics()` will update the pin using the
same `type` by default.

## See also

[`vetiver_compute_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_compute_metrics.md),
[`vetiver_plot_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_plot_metrics.md)

## Examples

``` r
library(dplyr)
library(parsnip)
data(Chicago, package = "modeldata")
Chicago <- Chicago |> select(ridership, date, all_of(stations))
training_data <- Chicago |> filter(date < "2009-01-01")
testing_data <- Chicago |> filter(date >= "2009-01-01", date < "2011-01-01")
monitoring <- Chicago |> filter(date >= "2011-01-01", date < "2012-12-31")
lm_fit <- linear_reg() |> fit(ridership ~ ., data = training_data)

library(pins)
b <- board_temp()

## before starting monitoring, initiate the metrics and pin
## (for example, with the testing data):
original_metrics <-
    augment(lm_fit, new_data = testing_data) |>
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
pin_write(b, original_metrics, "lm_fit_metrics", type = "arrow")
#> Creating new version '20251213T203901Z-4eb11'
#> Writing to pin 'lm_fit_metrics'

## to continue monitoring with new data, compute metrics and update pin:
new_metrics <-
    augment(lm_fit, new_data = monitoring) |>
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
vetiver_pin_metrics(b, new_metrics, "lm_fit_metrics")
#> Replacing version '20251213T203901Z-4eb11' with
#> '20251213T203901Z-bd441'
#> Writing to pin 'lm_fit_metrics'
#> # A tibble: 162 × 5
#>    .index        .n .metric .estimator .estimate
#>    <date>     <int> <chr>   <chr>          <dbl>
#>  1 2009-01-01     7 rmse    standard       6.78 
#>  2 2009-01-01     7 rsq     standard       0.154
#>  3 2009-01-01     7 mae     standard       5.25 
#>  4 2009-01-08    28 rmse    standard       4.61 
#>  5 2009-01-08    28 rsq     standard       0.576
#>  6 2009-01-08    28 mae     standard       2.98 
#>  7 2009-02-05    28 rmse    standard       1.90 
#>  8 2009-02-05    28 rsq     standard       0.916
#>  9 2009-02-05    28 mae     standard       1.17 
#> 10 2009-03-05    28 rmse    standard       1.24 
#> # ℹ 152 more rows
```
