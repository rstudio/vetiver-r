#' Deploy a vetiver model API to Posit Connect
#'
#' Use `vetiver_deploy_rsconnect()` to deploy a [vetiver_model()] that has been
#' versioned and stored via [vetiver_pin_write()] as a Plumber API on [Posit
#' Connect](https://docs.posit.co/connect/).
#'
#' @inheritParams vetiver_write_plumber
#' @param predict_args A list of optional arguments passed to [vetiver_api()]
#' such as the prediction `type`.
#' @param appTitle The API title on Posit Connect. Use the default based on
#' `name`, or pass in your own title.
#' @param ... Other arguments passed to [rsconnect::deployApp()] such as
#' `appName`, `account`, or `launch.browser`.
#'
#' @details The two functions `vetiver_deploy_rsconnect()` and
#' [vetiver_create_rsconnect_bundle()] are alternatives to each other, providing
#' different strategies for deploying a vetiver model API to Posit Connect.
#'
#' When you first deploy to Connect, your API will only be accessible to you.
#' You can [change the access settings](https://docs.posit.co/connect/user/content-settings/#set-viewers)
#' so others can also access the API. For all access settings other than
#' "Anyone - no login required", anyone querying your API (including you)
#' will need to pass authentication details with your API call,
#' [as shown in the Connect documentation](https://docs.posit.co/connect/user/vetiver/#predict-from-your-model-endpoint).
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
                                     ...,
                                     additional_pkgs = character(0)) {

    check_dots_used()
    tmp <- fs::dir_create(tempdir(), "vetiver")
    vetiver_write_plumber(board = board,
                          name = name,
                          version = version,
                          !!!predict_args,
                          file = fs::path(tmp, "plumber.R"),
                          additional_pkgs = additional_pkgs)
    rsconnect::deployAPI(tmp, appTitle = appTitle, ...)

}

#' Create an Posit Connect bundle for a vetiver model API
#'
#' Use `vetiver_create_rsconnect_bundle()` to create a 
#' [Posit Connect](https://docs.posit.co/connect/) model API bundle for a 
#' [vetiver_model()] that has been versioned and stored via 
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
#' [Posit Connect docs](https://docs.posit.co/connect/cookbook/deploying/)
#' for how to deploy this bundle, as well as the
#' [connectapi](https://pkgs.rstudio.com/connectapi/) R package for how to
#' integrate with Connect's API from R.
#'
#' The two functions `vetiver_create_rsconnect_bundle()` and
#' [vetiver_deploy_rsconnect()] are alternatives to each other, providing
#' different strategies for deploying a vetiver model API to Posit Connect.
#'
#' @examplesIf rlang::is_installed("connectapi") && identical(Sys.getenv("NOT_CRAN"), "true")
#' library(pins)
#' b <- board_temp(versioned = TRUE)
#' cars_lm <- lm(mpg ~ ., data = mtcars)
#' v <- vetiver_model(cars_lm, "cars_linear")
#' vetiver_pin_write(b, v)
#'
#' ## when you pin to Posit Connect, your pin name will be typically be like:
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
        filename = fs::file_temp(pattern = "bundle", ext = ".tar.gz"),
        additional_pkgs = character(0)) {

    tmp <- fs::dir_create(tempdir(), "vetiver")
    vetiver_write_plumber(board = board,
                          name = name,
                          version = version,
                          !!!predict_args,
                          file = fs::path(tmp, "plumber.R"),
                          additional_pkgs = additional_pkgs)
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

mock_write_manifest <- function(appDir, appFiles) {
    fs::file_create(fs::path(appDir, "manifest.json"))
}
