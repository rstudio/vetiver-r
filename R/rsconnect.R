#' Deploy a vetiver model API to RStudio Connect
#'
#' Use `vetiver_deploy_rsconnect()` to deploy a [vetiver_model()] that has been
#' versioned and stored via [vetiver_pin_write()] as a Plumber API on RStudio
#' Connect.
#'
#' @inheritParams vetiver_write_plumber
#' @param predict_args A list of optional arguments passed to [vetiver_api()]
#' such as the endpoint `path` or prediction `type`.
#' @param appTitle The API title on RStudio Connect. Use the default based on
#' `name`, or pass in your own title.
#' @param ... Other arguments passed to [rsconnect::deployApp()] such as
#' `account` or `launch.browser`.
#'
#' @details The two functions `vetiver_deploy_rsconnect()` and
#' [vetiver_create_rsconnect_bundle()] are alternatives to each other, providing
#' different strategies for deploying a vetiver model API to RStudio Connect.
#'
#' @return
#' The deployment success (`TRUE` or `FALSE`), invisibly.
#'
#' @seealso [vetiver_write_plumber()], [vetiver_create_rsconnect_bundle()]
#' @export
#'
#' @examplesIf rlang::is_installed("rsconnect")
#' library(pins)
#' b <- board_temp(versioned = TRUE)
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' if (FALSE) {
#' ## pass args for predicting:
#' vetiver_deploy_rsconnect(
#'     b,
#'     "user.name/cars_linear",
#'     predict_args = list(debug = TRUE)
#' )
#'
#' ## specify an account name through `...`:
#' vetiver_deploy_rsconnect(
#'     b,
#'     "user.name/cars_linear",
#'     account = "user.name"
#' )
#' }
#'
vetiver_deploy_rsconnect <- function(board, name, version = NULL,
                                     predict_args = list(),
                                     appTitle = glue::glue("{name} model API"),
                                     ...) {

    tmp <- fs::dir_create(tempdir(), "vetiver")
    vetiver_write_plumber(board = board,
                          name = name,
                          version = version,
                          !!!predict_args,
                          file = file.path(tmp, "plumber.R"))

    rsconnect::deployAPI(tmp, appTitle = appTitle, ...)

}

#' Create an RStudio Connect bundle for a vetiver model API
#'
#' Use `vetiver_create_rsconnect_bundle()` to create an RStudio Connect model
#' API bundle for a [vetiver_model()] that has been versioned and stored via
#' [vetiver_pin_write()].
#'
#' @inheritParams vetiver_write_plumber
#' @inheritParams vetiver_deploy_rsconnect
#' @param filename The path for the model API bundle to be created (can be
#' used as the argument to `connectapi::bundle_path()`)
#'
#' @return The location of the model API bundle `filename`, invisibly.
#' @seealso [vetiver_write_plumber()], [vetiver_deploy_rsconnect()]
#' @details This function creates a deployable bundle. See
#' [RStudio Connect docs](https://docs.rstudio.com/connect/cookbook/deploying/)
#' for how to deploy this bundle, as well as the
#' [connectapi](https://pkgs.rstudio.com/connectapi/) R package for how to
#' integrate with Connect's API from R.
#'
#' The two functions `vetiver_create_rsconnect_bundle()` and
#' [vetiver_deploy_rsconnect()] are alternatives to each other, providing
#' different strategies for deploying a vetiver model API to RStudio Connect.
#'
#' @examplesIf rlang::is_installed("connectapi") && identical(Sys.getenv("NOT_CRAN"), "true")
#' library(pins)
#' b <- board_temp(versioned = TRUE)
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' ## when you pin to RStudio Connect, your pin name will be typically be like:
#' ## "user.name/cars_linear"
#' vetiver_create_rsconnect_bundle(
#'     b,
#'     "cars_linear",
#'     predict_args = list(debug = TRUE)
#' )
#'
#' @export
vetiver_create_rsconnect_bundle <- function(
        board, name, version = NULL,
        predict_args = list(),
        filename = fs::file_temp(pattern = "bundle", ext = ".tar.gz")) {

    tmp <- fs::dir_create(tempdir(), "vetiver")
    vetiver_write_plumber(board = board,
                          name = name,
                          version = version,
                          !!!predict_args,
                          file = fs::path(tmp, "plumber.R"))
    rsconnect::writeManifest(tmp, "plumber.R")
    withr::with_dir(
        tmp,
        utils::tar(
            tarfile = filename,
            files = c("plumber.R", "manifest.json"),
            compression = "gzip",
            tar = "internal"
        )
    )
    inform(c("Your rsconnect bundle has been created at:", filename))
    invisible(filename)

}
