#' Deploy a vetiver model API to RStudio Connect
#'
#' Use `vetiver_deploy_rsconnect()` to deploy a [vetiver_model()] that has been
#' versioned and stored via [vetiver_pin_write()] as a Plumber API on RStudio
#' Connect.
#'
#' @inheritParams vetiver_write_plumber
#' @param predict_args A list of optional arguments passed to
#' [vetiver_pr_predict()] such as the endpoint `path` or prediction `type`.
#' @param appTitle The API title on RStudio Connect. Use the default based on
#' `name`, or pass in your own title.
#' @param ... Other arguments passed to [rsconnect::deployApp()] such as
#' `account` or `launch.browser`.
#'
#' @return
#' The deployment success (`TRUE` or `FALSE`), invisibly.
#'
#' @seealso [vetiver_write_plumber()]
#' @export
#'
#' @examples
#' library(pins)
#' tmp <- tempfile()
#' b <- board_temp(versioned = TRUE)
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' if (FALSE) {
#' vetiver_deploy_rsconnect(b, "cars_linear", predict_args = list(debug = TRUE))
#' }
#'
vetiver_deploy_rsconnect <- function(board, name, version = NULL,
                                     predict_args = list(),
                                     appTitle = glue::glue("{name} model API"),
                                     ...) {

    tmp <- tempdir()
    vetiver_write_plumber(board = board,
                          name = name,
                          version = version,
                          !!!predict_args,
                          file = file.path(tmp, "plumber.R"))

    rsconnect::deployAPI(tmp, appTitle = appTitle, ...)

}
