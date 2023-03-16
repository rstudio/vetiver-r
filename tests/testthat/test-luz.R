skip_on_cran()
skip_if_not_installed(pkg = c("torch", "luz", "plumber"))
torch::install_torch()

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test  <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1, drop=FALSE]

set.seed(1)

fitted <- torch::nn_linear %>%
    luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
    luz::set_hparams(in_features = ncol(x_train), out_features = 1) %>%
    luz::set_opt_hparams(lr = 0.01) %>%
    luz::fit(list(x_train, y_train), verbose = FALSE, dataloader_options = list(batch_size = 5))

v <- vetiver_model(
    fitted,
    "luz-model",
    prototype_data = data.frame(x_train)[1,]
)

test_that("can print a `vetiver`ed luz model", {
    expect_snapshot(v)
})

test_that("can predict a `vetiver`ed luz model", {
    v_preds <- predict(v, x_test)$cpu()
    l_preds <- predict(fitted, x_test)$cpu()

    expect_equal(as.array(v_preds), as.array(l_preds))
})

test_that("can pin a luz model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "luz-model")
    expect_equal(pinned$ptype, NULL)
    expect_equal(pin_meta(b, "luz-model")$user$required_pkgs, "luz")
})

test_that("endpoints for luz", {
    p <- plumber::pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_equal(names(p_routes), c("ping", "predict"))
    expect_equal(map_chr(p_routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

