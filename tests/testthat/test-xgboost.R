skip_if_not_installed("xgboost")
skip_if_not_installed("plumber")

library(plumber)
set.seed(123)
cars_xgb <- xgboost::xgboost(as.matrix(mtcars[,-1]),
                             mtcars$mpg, nrounds = 3,
                             objective = "reg:squarederror")
v <- vetiver_model(cars_xgb, "cars2")

test_that("can print xgboost model", {
    expect_snapshot(v)
})

test_that("can predict xgboost model", {
    cars_matrix <- as.matrix(mtcars[,-1])
    preds <- predict(v, cars_matrix)
    expect_equal(length(preds), 32)
    preds2 <- predict(cars_xgb, cars_matrix)
    expect_equal(preds, preds2)
})


test_that("can pin an xgboost model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars2")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(cars_xgb),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        )
    )
    expect_equal(
        pin_meta(b, "cars2")$user$required_pkgs,
        "xgboost"
    )
})

test_that("default endpoint for xgboost", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
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

