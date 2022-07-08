library(pins)
library(plumber)
skip_if_not_installed("tabnet")

set.seed(321)
cars_tn <- tabnet::tabnet_fit(mpg ~ ., data = mtcars, epoch=30)
v <- vetiver_model(cars_tn, "cars3", ptype_data = mtcars[,-1])

test_that("can print tabnet model", {
    expect_snapshot(v)
})

test_that("error for no ptype_data with tabnet", {
    expect_snapshot(vetiver_model(car_tn, "cars3"), error = TRUE)
})

test_that("can predict tabnet model", {
    preds <- predict(v, mtcars[,-1])
    expect_equal(length(preds$.pred), 32)
    expect_equal(mean(preds$.pred), 20.1, tolerance = 6)
})


test_that("can pin an tabnet model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars3")
    expect_equal(pinned$model, butcher::butcher(cars_tn))
    expect_equal(
        pinned$ptype,
        vctrs::vec_slice(tibble::as_tibble(mtcars[,-1]), 0)
    )
    expect_equal(
        pinned$required_pkgs,
        "tabnet"
    )
})

test_that("default endpoint for tabnet", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_equal(names(p_routes), c("ping", "predict"))
    expect_equal(purrr::map_chr(p_routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A tabnet regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for tabnet", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars3", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

