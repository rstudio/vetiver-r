#' R Markdown format for model monitoring dashboards
#'
#' @inheritParams pins::pin_write
#' @param pins A list containing `board`, `name`, and `version`, as in
#' [pins::pin_read()]
#' @param display_pins Should the dashboard display a link to the pin(s)?
#' Defaults to `TRUE`, but only creates a link if the pin contains a URL in
#' its metadata.
#' @param ... Arguments passed to [flexdashboard::flex_dashboard()]
#'
#' @details The `vetiver_dashboard()` function is a specialized type of
#' \pkg{flexdashboard}. See the flexdashboard website for additional
#' documentation:
#'  \href{http://rmarkdown.rstudio.com/flexdashboard/}{http://rmarkdown.rstudio.com/flexdashboard/}
#'
#' Before knitting the example `vetiver_dashboard()` template, execute the
#' helper function `pin_example_kc_housing_model()` to set up demonstration
#' model and metrics pins needed for the monitoring demo. This function will:
#'
#' - fit an example model to training data
#' - pin the vetiver model to your own [pins::board_local()]
#' - compute metrics from testing data
#' - pin these metrics to the same local board
#'
#' These are the steps you need to complete before setting up monitoring your
#' real model.
#'
#' @export
vetiver_dashboard <- function(pins, display_pins = TRUE, ...) {

    rlang::check_installed("flexdashboard")
    dashboard_dots <- rlang::list2(...)
    v <- dashboard_read_version(
        pins$board,
        pins$name,
        pins$version
    )

    if (display_pins && !is_null(v$metadata$url)) {
        dashboard_dots <- vetiver_modify_navbar(dashboard_dots, v$metadata$url)
    }
    if (is_null(dashboard_dots$favicon)) {
        vetiver_fav <- system.file("favicon.ico", package = "vetiver")
        dashboard_dots <- modifyList(dashboard_dots, list(favicon = vetiver_fav))
    }

    rmarkdown::output_format(
        knitr = rmarkdown::knitr_options(
            opts_knit = list(vetiver_dashboard.pins = pins),
            # require to keep flexdashboard one
            opts_chunk = list(),
            knit_hooks = list(),
            opts_hooks = list(),
            opts_template = list()
        ),
        pandoc = NULL,
        base_format = rlang::inject(flexdashboard::flex_dashboard(!!!dashboard_dots))
    )
}


dashboard_read_version <- function(board, name, version, call = rlang::caller_env()) {
    if (!pins::pin_exists(board, name)) {
        rlang::abort(
            c(
                glue("The pin {glue::double_quote(name)} does not exist on your board"),
                "*" = "Check the `pins` params in your dashboard YAML",
                "i" = glue("To knit the example vetiver monitoring dashboard, \\
                       execute `vetiver::pin_example_kc_housing_model()` to \\
                       set up demo model and metrics pins")
            ),
            call = call)
    }
    if (board$versioned) {
        if (is_null(version)) {
            version <- pins::pin_versions(board, name)
            version <- choose_version(version)
        }
        v <- vetiver_pin_read(board, name, version = version)
    } else {
        v <- vetiver_pin_read(board, name)
    }
    v
}

vetiver_modify_navbar <- function(dots, url) {
    if(has_name(dots, "navbar")) {
        navbar <- dots$navbar
    } else {
        navbar <- NULL
    }
    pin_navbar <- list(
        title = "Model Pin",
        icon = "fa-map-marker",
        href = url,
        target = "_blank"
    )
    navbar <- append(navbar, list(pin_navbar))
    modifyList(dots, list(navbar = navbar))
}


#' @rdname vetiver_dashboard
#' @export
get_vetiver_dashboard_pins <- function() {
    knitr::opts_knit$get("vetiver_dashboard.pins")
}

#' @rdname vetiver_dashboard
#' @export
pin_example_kc_housing_model <- function(board = pins::board_local(),
                                         name = "seattle_rf") {

    df <- mlr3data::kc_housing
    df_train <- dplyr::filter(df, date < "2014-11-01")
    df_test  <- dplyr::filter(df, date >= "2014-11-01", date < "2015-01-01")
    rf_spec <- parsnip::rand_forest(trees = 200, mode = "regression")

    rf_fit <-
        workflows::workflow(price ~ bedrooms + bathrooms +
                                sqft_living + yr_built, rf_spec) %>%
        parsnip::fit(df_train)

    v <- vetiver_model(rf_fit, name)
    vetiver_pin_write(board, v)

    old_metrics <-
        parsnip::augment(v, df_test %>% dplyr::arrange(date)) %>%
        vetiver_compute_metrics(date, "week", price, .pred)

    pins::pin_write(board, old_metrics, paste(name, "metrics", sep = "_"))

}


