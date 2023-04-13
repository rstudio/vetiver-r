skip_if_not_installed("recipes")
skip_if_not_installed("plumber")

library(plumber)
library(recipes)

trained_rec <-
    recipe(mpg ~ disp + wt, mtcars) %>%
    step_ns(wt) %>%
    prep(retain = FALSE)

v <- vetiver_model(trained_rec, "car-splines", prototype_data = mtcars[c("disp", "wt")])

test_that("can print recipe", {
    expect_snapshot(v)
})

test_that("can pin a recipe", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "car-splines")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(trained_rec)),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[c("disp", "wt")]), 0)
        )
    )
    expect_equal(
        pin_meta(b, "car-splines")$user$required_pkgs,
        c("recipes")
    )
})

test_that("default endpoint for recipe", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A feature engineering recipe with 1 step")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for recipe", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "car-splines", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

