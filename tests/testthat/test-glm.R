skip_if_not_installed("plumber")
library(plumber)

mtcars_glm <- glm(mpg ~ ., data = mtcars)
v <- vetiver_model(mtcars_glm, "cars_glm")

test_that("can print glm model", {
    expect_snapshot(v)
})

test_that("can predict glm model", {
    preds <- predict(v, mtcars)
    expect_type(preds, "double")
    expect_equal(mean(preds), 20.1, tolerance = 0.1)
})

test_that("can pin a glm model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars_glm")
    expect_equal(
        pinned,
        list(
            model = butcher::butcher(mtcars_glm),
            prototype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        ),
        ignore_function_env = TRUE,
        ignore_formula_env = TRUE
    )
    expect_equal(
        pin_meta(b, "cars_glm")$user$required_pkgs,
        NULL
    )
})

test_that("default endpoint for glm", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A generalized linear model (gaussian family, identity link)")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for glm", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars_glm", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})


test_that("prototype for glm with interactions", {
    cars_interaction <- glm(mpg ~ cyl * vs + disp, data = mtcars)
    expect_equal(
        vetiver_create_ptype(cars_interaction, TRUE),
        vctrs::vec_slice(tibble::as_tibble(mtcars[, c(2, 8, 3)]), 0)
    )
})

