skip_on_cran()
skip_if_not_installed(pkg = c("torch", "luz", "plumber"))
torch::install_torch()

fitted <- torch::nn_linear %>%
    luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
    luz::set_hparams(in_features = 10, out_features = 1) %>%
    luz::set_opt_hparams(lr = 0.01) %>%
    luz::fit(list(torch::torch_randn(100, 10), torch::torch_randn(100, 1)), verbose = FALSE)

v <- vetiver_model(
    fitted,
    "luz-model",
    prototype_data = torch::torch_randn(10, 10)
)

test_that("can print a `vetiver`ed luz model", {
    expect_snapshot(v)
})

test_that("can predict a `vetiver`ed luz model", {
    x <- torch::torch_randn(10, 10)
    v_preds <- predict(v, x)$cpu()
    l_preds <- predict(fitted, x)$cpu()

    expect_equal(as.array(v_preds), as.array(l_preds))
})

test_that("can pin a luz model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "luz-model")
    expect_equal(pinned$ptype, NULL)
    expect_equal(pin_meta(b, "luz-model")$user$required_pkgs, "luz")
})

test_path("endpoints for luz", {
    p <- plumber::pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_equal(names(p_routes), c("ping", "predict"))
    expect_equal(map_chr(p_routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

test_that("works for non-retangular data", {
    module <- torch::nn_module(
        initialize = function() {
            self$linear <- torch::nn_linear(10, 2)
        },
        forward = function(x) {
            if (!all(x$shape[-1] == c(1,5,2))) stop("dim error")
            x <- torch::torch_flatten(x, start_dim = 2)
            x <- self$linear(x)
            x$view(c(-1, 1, 2))
        }
    )

    fitted <- module %>%
        luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
        luz::set_opt_hparams(lr = 0.01) %>%
        luz::fit(list(torch::torch_randn(100, 1, 5, 2), torch::torch_randn(100, 1, 2)), verbose = FALSE)

    v <- vetiver_model(
        fitted,
        "luz-model",
        prototype_data = torch::torch_randn(10, 1, 5, 2)
    )

    x <- as.array(torch::torch_randn(10, 1, 5, 2))
    v_preds <- predict(v, x)$cpu()
    l_preds <- predict(fitted, x)$cpu()

    expect_equal(as.array(v_preds), as.array(l_preds))
    expect_error(predict(v, as.array(torch::torch_randn(10, 2))), regex = "dim error")
})

test_that("can call endpoints", {
    session <- callr::r_session$new()
    session$call(function() {
        library(magrittr)
        library(vetiver)
        module <- torch::nn_module(
            initialize = function() {
                self$linear <- torch::nn_linear(10, 2)
            },
            forward = function(x) {
                if (!all(x$shape[-1] == c(1,5,2))) stop("dim error")
                x <- torch::torch_flatten(x, start_dim = 2)
                x <- self$linear(x)
                x$view(c(-1, 1, 2))
            }
        )

        fitted <- module %>%
            luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
            luz::set_opt_hparams(lr = 0.01) %>%
            luz::fit(list(torch::torch_randn(100, 1, 5, 2), torch::torch_randn(100, 1, 2)), verbose = FALSE)

        v <- vetiver::vetiver_model(
            fitted,
            "luz-model",
            prototype_data = torch::torch_randn(10, 1, 5, 2)
        )

        p <- plumber::pr() %>% vetiver_api(v)
        p$run(port = 3232)
    })
    endpoint <- vetiver_endpoint("http://127.0.0.1:3232/predict")
    # wait for session to start plumber
    httr::RETRY("GET", "http://127.0.0.1:3232/ping", quiet = TRUE)

    predictions <- predict(endpoint, list(input = as.array(torch::torch_randn(10, 1, 5, 2))))
    expect_equal(nrow(predictions), 10)
    expect_equal(names(predictions), c(".pred"))

    predictions <- predict(endpoint, list(as.array(torch::torch_randn(10, 1, 5, 2))))
    expect_equal(nrow(predictions), 10)
    expect_equal(names(predictions), c(".pred"))

    predictions <- predict(endpoint, as.array(torch::torch_randn(10, 1, 5, 2)))
    expect_equal(nrow(predictions), 10)
    expect_equal(names(predictions), c(".pred"))
})
