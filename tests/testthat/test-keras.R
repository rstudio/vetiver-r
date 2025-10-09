skip_on_cran()
skip_if_not_installed("keras")
skip_if_not_installed("plumber")

library(plumber)
library(keras)
py_require_legacy_keras()
reticulate::py_require("tensorflow-datasets", action = "remove")

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1]

set.seed(1)

keras_fit <-
    keras_model_sequential(input_shape = ncol(x_train)) %>%
    layer_dense(units = 1, activation = 'linear') %>%
    compile(loss = 'mean_squared_error')

keras_fit %>%
    fit(
        x = x_train,
        y = y_train,
        epochs = 100,
        batch_size = 1,
        verbose = 0
    )

v <- vetiver_model(
    keras_fit,
    "cars-keras",
    prototype_data = data.frame(x_train)[1, ]
)

test_that("can print keras model", {
    expect_snapshot(v)
})

test_that("can predict keras model", {
    preds <- predict(v, x_test)
    expect_type(preds, "double")
    expect_equal(length(preds), 7)
})

test_that("can pin a keras model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars-keras")
    ## STILL NOT EQUAL because of serialization issues, even with bundle
    ## expect_equal(pinned$model, bundle::bundle(keras_fit))
    expect_equal(pinned$ptype, NULL)
    expect_equal(pin_meta(b, "cars-keras")$user$required_pkgs, "keras")
})

test_that("default endpoint for keras", {
    p <- pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(
        car_spec$info$description,
        "A sequential keras model with 2 layers"
    )
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(
        as.character(post_spec$summary),
        "Return predictions from model using 10 features"
    )
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(
        as.character(get_spec$summary),
        "Get URL of pinned vetiver model"
    )
})

test_that("create plumber.R for keras", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars-keras", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
    expect_snapshot(
        cat(
            readr::read_lines(fs::path(fs::path_dir(tmp), "requirements.txt")),
            sep = "\n"
        ),
        transform = redact_vetiver
    )
    expect_snapshot(
        vetiver_write_docker(v, tmp, tmp_dir)
    )
})
