# R Markdown format for model monitoring dashboards

R Markdown format for model monitoring dashboards

## Usage

``` r
vetiver_dashboard(pins = list(), display_pins = TRUE, ...)

get_vetiver_dashboard_pins()

pin_example_kc_housing_model(board = pins::board_local(), name = "seattle_rf")
```

## Arguments

- pins:

  A list containing `board`, `name`, and `version`, as in
  [`pins::pin_read()`](https://pins.rstudio.com/reference/pin_read.html)

- display_pins:

  Should the dashboard display a link to the pin(s)? Defaults to `TRUE`,
  but only creates a link if the pin contains a URL in its metadata.

- ...:

  Arguments passed to
  [`flexdashboard::flex_dashboard()`](https://pkgs.rstudio.com/flexdashboard/reference/flex_dashboard.html)

- board:

  A pin board, created by
  [`board_folder()`](https://pins.rstudio.com/reference/board_folder.html),
  [`board_connect()`](https://pins.rstudio.com/reference/board_connect.html),
  [`board_url()`](https://pins.rstudio.com/reference/board_url.html) or
  another `board_` function.

- name:

  Pin name.

## Details

The `vetiver_dashboard()` function is a specialized type of
flexdashboard. See the flexdashboard website for additional
documentation: <https://pkgs.rstudio.com/flexdashboard/>

Before knitting the example `vetiver_dashboard()` template, execute the
helper function `pin_example_kc_housing_model()` to set up demonstration
model and metrics pins needed for the monitoring demo. This function
will:

- fit an example model to training data

- pin the vetiver model to your own
  [`pins::board_local()`](https://pins.rstudio.com/reference/board_folder.html)

- compute metrics from testing data

- pin these metrics to the same local board

These are the steps you need to complete before setting up monitoring
your real model.
