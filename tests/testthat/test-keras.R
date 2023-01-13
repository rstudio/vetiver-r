skip_on_cran()
skip_if_not_installed("keras")
skip_if_not_installed("plumber")
skip_if(is.null(tensorflow::tf_version()))

library(plumber)
library(keras)

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test  <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1]

set.seed(1)

keras_fit <-
    keras_model_sequential()  %>%
    layer_dense(units = 1, input_shape = ncol(x_train), activation = 'linear') %>%
    compile(
        loss = 'mean_squared_error',
        optimizer = optimizer_adam(learning_rate = .01)
    )

keras_fit %>%
    fit(
        x = x_train, y = y_train,
        epochs = 100, batch_size = 1,
        verbose = 0
    )

v <- vetiver_model(keras_fit, "cars-keras")

test_that("can print keras model", {
    expect_snapshot(v)
})

test_that("can predict keras model", {
    preds <- predict(v, x_test)
    expect_type(preds, "double")
    expect_equal(length(preds), 7)
    expect_equal(mean(preds), 0.5, tolerance = 0.1)
})

test_that("can pin a keras model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars-keras")
    ## STILL NOT EQUAL because of serialization issues, even with bundle
    ## expect_equal(pinned$model, bundle::bundle(mod))
    expect_equal(pinned$ptype, NULL)
    expect_equal(pinned$required_pkgs, "keras")
})

test_that("default endpoint for keras", {
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
                 "A sequential keras model with 2 layers")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

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
})
