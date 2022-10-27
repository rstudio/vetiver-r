skip_if_not_installed("mgcv")

mtcars_gam <- mgcv::gam(mpg ~ s(disp, k = 3) + s(wt), data = mtcars)
v <- vetiver_model(mtcars_gam, "cars_gam")

test_that("can print gam model", {
    expect_snapshot(v)
})

test_that("can predict gam model", {
    preds <- predict(v, mtcars)
    expect_type(preds, "double")
    expect_equal(mean(preds), 20.1, tolerance = 0.1)
})

test_that("can pin a gam model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars_gam")
    expect_equal(
        pinned,
        list(
            model = butcher::butcher(mtcars_gam),
            ptype = vctrs::vec_ptype(tibble::as_tibble(mtcars[, c(3, 6)])),
            required_pkgs = "mgcv"
        ),
        ignore_function_env = TRUE,
        ignore_formula_env = TRUE
    )
})

test_that("default endpoint for gam", {
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
                 "A generalized additive model (gaussian family, identity link)")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for xgboost", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_gam", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})
