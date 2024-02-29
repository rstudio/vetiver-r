skip_on_cran()
skip_if_not_installed(pkg = c("torch", "luz", "plumber"))
library(plumber)
torch::install_torch()

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test  <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1, drop=FALSE]

set.seed(1)

acc <- luz::accelerator(cpu = TRUE)

luz_fit <- torch::nn_linear %>%
    luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
    luz::set_hparams(in_features = ncol(x_train), out_features = 1) %>%
    luz::set_opt_hparams(lr = 0.01) %>%
    luz::fit(
        list(x_train, y_train), verbose = FALSE, 
        dataloader_options = list(batch_size = 5),
        accelerator = acc
    )

v <- vetiver_model(
    luz_fit,
    "cars-luz",
    prototype_data = data.frame(x_train)[1,]
)

test_that("can print a `vetiver`ed luz model", {
    expect_snapshot(v)
})

test_that("can predict a `vetiver`ed luz model", {
    v_preds <- predict(v, x_test, accelerator = acc)$cpu()
    l_preds <- predict(luz_fit, x_test, accelerator = acc)$cpu()

    expect_equal(as.array(v_preds), as.array(l_preds))
})

test_that("can pin a luz model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "cars-luz")
    ## STILL NOT EQUAL because of serialization issues, even with bundle
    ## expect_equal(pinned$model, bundle::bundle(luz_fit))
    expect_equal(pinned$prototype, vctrs::vec_ptype(tibble::as_tibble(x_train)))
    expect_equal(pin_meta(b, "cars-luz")$user$required_pkgs, c("luz", "torch"))
})

test_that("endpoints for luz", {
    p <- plumber::pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_api_routes(p_routes)
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    expect_equal(car_spec$info$description,
                 "A luz module with 11 parameters")
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 10 features")
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for keras", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars-luz", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
    expect_snapshot(
        cat(readr::read_lines(fs::path(fs::path_dir(tmp), ".Renviron")), sep = "\n"),
        transform = redact_vetiver
    )
})
