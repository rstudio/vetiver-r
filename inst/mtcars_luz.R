library(vetiver)
library(plumber)
library(torch)

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test  <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1, drop = FALSE]

set.seed(1)

luz_module <- torch::nn_module(
    initialize = function(in_features, out_features) {
        self$linear <- nn_linear(in_features, out_features)
    },
    forward = function(x) {
        if (self$training) {
            self$linear(x)
        } else {
            torch_randn(dim(x)[1], 3, 64, 64, device = self$linear$weight$device)
        }

    }
)

luz_fit <- luz_module %>%
    luz::setup(loss = torch::nnf_mse_loss, optimizer = torch::optim_sgd) %>%
    luz::set_hparams(in_features = ncol(x_train), out_features = 1) %>%
    luz::set_opt_hparams(lr = 0.01) %>%
    luz::fit(list(x_train, y_train), verbose = FALSE, dataloader_options = list(batch_size = 5))

v <- vetiver_model(luz_fit, "cars-luz", prototype_data = data.frame(x_train)[1,])
pr() %>% vetiver_api(v, debug = TRUE) %>% pr_run(port = 8080)

##### in new session: ##########################################################
# library(vetiver)
# endpoint <- vetiver_endpoint("http://127.0.0.1:8080/predict")
# x_test <- dplyr::slice(data.frame(scale(mtcars)), 26:32)
# predict(endpoint, x_test[1:2,])
