skip_if_not_installed("workflows")
skip_if_not_installed("parsnip")
skip_if_not_installed("ranger")
skip_if_not_installed("plumber")

library(plumber)
library(workflows)
library(parsnip)
library(probably)

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

set.seed(123)
mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

mtcars_int_split <- int_conformal_split(mtcars_wf, mtcars)
mtcars_int_full <- int_conformal_full(mtcars_wf, mtcars)

v_split <- vetiver_model(mtcars_int_split, "cars_int_split")
v_full <- vetiver_model(mtcars_int_full, "cars_int_full")

test_that("can print int_conformal_split model", {
    expect_snapshot(v_split)
})

test_that("can predict int_conformal_split model", {
    preds <- predict(v_split, mtcars)
    expect_s3_class(preds, "tbl_df")
    expect_equal(mean(preds$.pred), 20.1, tolerance = 0.1)
})

test_that("can pin a int_conformal_split model", {
    b <- board_temp()
    vetiver_pin_write(b, v_split)
    pinned <- pin_read(b, "cars_int_split")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(mtcars_int_split)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        ),
        ignore_formula_env = TRUE
    )
    expect_equal(
        pin_meta(b, "cars_int_split")$user$required_pkgs,
        c("parsnip", "ranger", "workflows", "probably")
    )
})

test_that("default endpoint for int_conformal_split", {
    p <- pr() %>% vetiver_api(v_split)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v_split$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v_split)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A Split Conformal inference with a ranger regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")
})

test_that("create plumber.R for int_conformal_split", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v_split)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_int_split", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("can print int_conformal_full model", {
    expect_snapshot(v_full)
})

test_that("can predict int_conformal_full model", {
    preds <- predict(v_full, mtcars[1, ])
    expect_s3_class(preds, "tbl_df")
    expect_true(all(c(".pred_lower", ".pred_upper") %in% names(preds)))
})

test_that("can pin a int_conformal_full model", {
    b <- board_temp()
    vetiver_pin_write(b, v_full)
    pinned <- pin_read(b, "cars_int_full")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(mtcars_int_full)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        ),
        ignore_formula_env = TRUE
    )
    expect_equal(
        pin_meta(b, "cars_int_full")$user$required_pkgs,
        c("parsnip", "ranger", "workflows", "probably")
    )
})

test_that("default endpoint for int_conformal_full", {
    p <- pr() %>% vetiver_api(v_full)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v_full$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v_full)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A full Conformal inference with a ranger regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")
})

test_that("create plumber.R for int_conformal_full", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v_full)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_int_full", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

