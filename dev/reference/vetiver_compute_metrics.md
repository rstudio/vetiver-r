# Aggregate model metrics over time for monitoring

These three functions can be used for model monitoring (such as in a
monitoring dashboard):

- `vetiver_compute_metrics()` computes metrics (such as accuracy for a
  classification model or RMSE for a regression model) at a chosen time
  aggregation `period`

- [`vetiver_pin_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_metrics.md)
  updates an existing pin storing model metrics over time

- [`vetiver_plot_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_plot_metrics.md)
  creates a plot of metrics over time

## Usage

``` r
vetiver_compute_metrics(
  data,
  date_var,
  period,
  truth,
  estimate,
  ...,
  metric_set = yardstick::metrics,
  every = 1L,
  origin = NULL,
  before = 0L,
  after = 0L,
  complete = FALSE
)
```

## Arguments

- data:

  A `data.frame` containing the columns specified by `truth`,
  `estimate`, and `...`.

- date_var:

  The column in `data` containing dates or date-times for monitoring, to
  be aggregated with `.period`

- period:

  `[character(1)]`

  A string defining the period to group by. Valid inputs can be roughly
  broken into:

  - `"year"`, `"quarter"`, `"month"`, `"week"`, `"day"`

  - `"hour"`, `"minute"`, `"second"`, `"millisecond"`

  - `"yweek"`, `"mweek"`

  - `"yday"`, `"mday"`

- truth:

  The column identifier for the true results (that is `numeric` or
  `factor`). This should be an unquoted column name although this
  argument is passed by expression and support
  [quasiquotation](https://rlang.r-lib.org/reference/topic-inject.html)
  (you can unquote column names).

- estimate:

  The column identifier for the predicted results (that is also
  `numeric` or `factor`). As with `truth` this can be specified
  different ways but the primary method is to use an unquoted variable
  name.

- ...:

  A set of unquoted column names or one or more `dplyr` selector
  functions to choose which variables contain the class probabilities.
  If `truth` is binary, only 1 column should be selected, and it should
  correspond to the value of `event_level`. Otherwise, there should be
  as many columns as factor levels of `truth` and the ordering of the
  columns should be the same as the factor levels of `truth`.

- metric_set:

  A
  [`yardstick::metric_set()`](https://yardstick.tidymodels.org/reference/metric_set.html)
  function for computing metrics. Defaults to
  [`yardstick::metrics()`](https://yardstick.tidymodels.org/reference/metrics.html).

- every:

  `[positive integer(1)]`

  The number of periods to group together.

  For example, if the period was set to `"year"` with an every value of
  `2`, then the years 1970 and 1971 would be placed in the same group.

- origin:

  `[Date(1) / POSIXct(1) / POSIXlt(1) / NULL]`

  The reference date time value. The default when left as `NULL` is the
  epoch time of `1970-01-01 00:00:00`, *in the time zone of the index*.

  This is generally used to define the anchor time to count from, which
  is relevant when the every value is `> 1`.

- before, after:

  `[integer(1) / Inf]`

  The number of values before or after the current element to include in
  the sliding window. Set to `Inf` to select all elements before or
  after the current element. Negative values are allowed, which allows
  you to "look forward" from the current element if used as the
  `.before` value, or "look backwards" if used as `.after`.

- complete:

  `[logical(1)]`

  Should the function be evaluated on complete windows only? If `FALSE`,
  the default, then partial computations will be allowed.

## Value

A dataframe of metrics.

## Details

For arguments used more than once in your monitoring dashboard, such as
`date_var`, consider using [R Markdown
parameters](https://bookdown.org/yihui/rmarkdown/parameterized-reports.html)
to reduce repetition and/or errors.

## See also

[`vetiver_pin_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_metrics.md),
[`vetiver_plot_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_plot_metrics.md)

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(parsnip)
data(Chicago, package = "modeldata")
Chicago <- Chicago |> select(ridership, date, all_of(stations))
training_data <- Chicago |> filter(date < "2009-01-01")
testing_data <- Chicago |> filter(date >= "2009-01-01", date < "2011-01-01")
monitoring <- Chicago |> filter(date >= "2011-01-01", date < "2012-12-31")
lm_fit <- linear_reg() |> fit(ridership ~ ., data = training_data)

library(pins)
b <- board_temp()

original_metrics <-
    augment(lm_fit, new_data = testing_data) |>
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)

new_metrics <-
    augment(lm_fit, new_data = monitoring) |>
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
```
