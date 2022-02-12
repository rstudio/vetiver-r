library(pins)
library(plumber)
skip_if_not_installed("ranger")

set.seed(123)
cars_rf <- ranger::ranger(mpg ~ ., data = mtcars, quantreg = TRUE)
v <- vetiver_model(cars_rf, "cars3", ptype_data = mtcars[,-1])

test_that("can print ranger model", {
    expect_snapshot(v)
})

test_that("error for no ptype_data with ranger", {
    expect_snapshot(vetiver_model(cars_rf, "cars3"), error = TRUE)
})

test_that("can predict ranger model", {
    preds <- predict(v, mtcars[,-1])
    expect_equal(length(preds$predictions), 32)
    expect_equal(mean(preds$predictions), 20.1, tolerance = 0.1)
})


test_that("can pin an ranger model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars3")
    expect_equal(pinned$model, butcher::butcher(cars_rf))
    expect_equal(
        pinned$ptype,
        vctrs::vec_slice(tibble::as_tibble(mtcars[,-1]), 0)
    )
    expect_equal(
        pinned$required_pkgs,
        "ranger"
    )
})

test_that("default endpoint for ranger", {
    p <- pr() %>% vetiver_api(v)
    expect_equal(names(p$routes), c("ping", "predict"))
    expect_equal(map_chr(p$routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A ranger regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for ranger", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars3", file = tmp)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})

