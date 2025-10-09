skip_if_not_installed("probably")
skip_if_not_installed("dplyr")
skip_if_not_installed("workflows")
skip_if_not_installed("parsnip")
skip_if_not_installed("ranger")
skip_if_not_installed("plumber")
skip_if_not_installed("tune")
skip_if_not_installed("rsample")
skip_if_not_installed("quantregForest")

library(plumber)
library(workflows)
library(parsnip)
library(probably)
library(tune)
library(rsample)
library(dplyr)

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

set.seed(123)
mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

mtcars_int_split <- int_conformal_split(mtcars_wf, mtcars)
mtcars_int_full <- int_conformal_full(mtcars_wf, mtcars)
mtcars_int_quantile <- int_conformal_quantile(mtcars_wf, mtcars, mtcars)

v_split <- vetiver_model(mtcars_int_split, "cars_int_split")
v_full <- vetiver_model(mtcars_int_full, "cars_int_full")
v_quantile <- vetiver_model(mtcars_int_quantile, "cars_int_quantile")

ctrl <- control_resamples(save_pred = TRUE, extract = I)

set.seed(1234)
mtcars_cv <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit_resamples(resamples = vfold_cv(mtcars), control = ctrl)
        
mtcars_int_cv <- int_conformal_cv(mtcars_cv)
        
v_cv <- vetiver_model(mtcars_int_cv, "cars_int_cv")

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

test_that("can print int_conformal_quantile model", {
    expect_snapshot(v_quantile)
})

test_that("can predict int_conformal_quantile model", {
    preds <- predict(v_quantile, mtcars[1, ])
    expect_s3_class(preds, "tbl_df")
    expect_true(all(c(".pred_lower", ".pred_upper") %in% names(preds)))
})

test_that("can pin a int_conformal_quantile model", {
    b <- board_temp()
    vetiver_pin_write(b, v_quantile)
    pinned <- pin_read(b, "cars_int_quantile")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(mtcars_int_quantile)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        ),
        ignore_formula_env = TRUE
    )
    expect_equal(
        pin_meta(b, "cars_int_quantile")$user$required_pkgs,
        c("parsnip", "ranger", "workflows", "probably")
    )
})

test_that("default endpoint for int_conformal_quantile", {
    p <- pr() %>% vetiver_api(v_quantile)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v_quantile$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v_quantile)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A quantile Conformal inference with a ranger regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")
})

test_that("create plumber.R for int_conformal_quantile", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v_quantile)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_int_quantile", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})


test_that("can print int_conformal_cv model", {
    expect_snapshot(v_cv)
})

test_that("can predict int_conformal_cv model", {
    preds <- predict(v_cv, mtcars[1, ])
    expect_s3_class(preds, "tbl_df")
    expect_true(all(c(".pred_lower", ".pred_upper") %in% names(preds)))
})

test_that("can pin a int_conformal_cv model", {
    b <- board_temp()
    vetiver_pin_write(b, v_cv)
    pinned <- pin_read(b, "cars_int_cv")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(mtcars_int_cv)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        ),
        ignore_formula_env = TRUE
    )
    expect_equal(
        pin_meta(b, "cars_int_cv")$user$required_pkgs,
        c("parsnip", "ranger", "workflows", "probably")
    )
})

test_that("default endpoint for int_conformal_cv", {
    p <- pr() %>% vetiver_api(v_cv)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v_cv$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v_cv)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A 10-fold CV+ Conformal inference with a ranger regression model")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")
})

test_that("create plumber.R for int_conformal_cv", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v_cv)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_int_cv", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

