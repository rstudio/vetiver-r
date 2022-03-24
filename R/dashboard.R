#' R Markdown format for model monitoring dashboards
#'
#' @param ... Arguments passed to [flexdashboard::flex_dashboard()]
#' @param display_pins Should the dashboard display a link to the pin(s)?
#' Defaults to `TRUE`.
#' @param display_api Should the dashboard display the OpenAPI documentation
#' for the deployed model? Defaults to `TRUE`.
#'
#' @details The `vetiver_dashboard()` function is a specialized type of
#' \pkg{flexdashboard}. See the flexdashboard website for additional
#' documentation:
#'  \href{http://rmarkdown.rstudio.com/flexdashboard/}{http://rmarkdown.rstudio.com/flexdashboard/}
#'
#' @export
vetiver_dashboard <- function(..., display_pins = TRUE, display_api = TRUE) {
    flexdashboard::flex_dashboard(...)
}
