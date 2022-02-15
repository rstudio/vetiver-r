library(pins)
library(plumber)
skip_if_not_installed("workflows")
skip_if_not_installed("parsnip")

library(workflows)
library(parsnip)

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

set.seed(123)
mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

v <- vetiver_model(mtcars_wf, "cars_wf")

test_that("can print tidymodels model", {
    expect_snapshot(v)
})

test_that("can predict tidymodels model", {
    preds <- predict(v, mtcars)
    expect_s3_class(preds, "tbl_df")
    expect_equal(mean(preds$.pred), 20.1, tolerance = 0.1)
})

test_that("can pin a tidymodels model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars_wf")
    expect_equal(
        pinned,
        list(
            model = butcher::butcher(mtcars_wf),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0),
            required_pkgs = c("parsnip", "ranger", "workflows")
        )
    )
})

test_that("default endpoint for tidymodels", {
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
                 "A ranger regression modeling workflow")
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
    b <- board_folder(path = "/tmp/test")
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_wf", file = tmp)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})

