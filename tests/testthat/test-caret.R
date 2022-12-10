skip_if_not_installed("caret")
skip_if_not_installed("ranger")
skip_if_not_installed("plumber")

library(caret)
library(plumber)

predictors <- mtcars[, c("cyl", "disp", "hp")]

set.seed(1)
rf_fit <-
    train(
        x = predictors,
        y = mtcars$mpg,
        method = "ranger",
        tuneLength = 2,
        trControl = trainControl(method = "cv")
    )

v <- vetiver_model(rf_fit, "cars_rf")

test_that("can print caret model", {
    expect_snapshot(v)
})

test_that("can pin a caret model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars_rf")
    expect_equal(
        pin_read(b, "cars_rf"),
        list(
            model = bundle::bundle(butcher::butcher(rf_fit)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:4]), 0),
            required_pkgs = c("caret", "dplyr", "e1071", "ranger")
        )
    )
})

test_that("default endpoint for caret", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_equal(names(p_routes), c("ping", "predict"))
    expect_equal(map_chr(p_routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A random forest regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 3 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for xgboost", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_rf", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

