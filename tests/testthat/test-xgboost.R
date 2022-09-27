skip_if_not_installed("xgboost")

set.seed(123)
cars_xgb <- xgboost::xgboost(as.matrix(mtcars[,-1]),
                             mtcars$mpg, nrounds = 3,
                             objective = "reg:squarederror")
v <- vetiver_model(cars_xgb, "cars2")

test_that("can print xgboost model", {
    expect_snapshot(v)
})

test_that("can predict xgboost model", {
    preds <- predict(v, as.matrix(mtcars[,-1]))
    expect_equal(length(preds), 32)
    expect_equal(mean(preds), 12.7, tolerance = 0.1)
})


test_that("can pin an xgboost model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars2")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(cars_xgb),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0),
            required_pkgs = c("xgboost")
        )
    )
})

test_that("default endpoint for xgboost", {
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
                 "An xgboost reg:squarederror model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for xgboost", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars2", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

