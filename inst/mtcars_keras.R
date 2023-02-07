library(vetiver)
library(plumber)
library(keras)

scaled_cars <- as.matrix(mtcars) %>% scale()
x_test  <- scaled_cars[26:32, 2:ncol(scaled_cars)]
x_train <- scaled_cars[1:25, 2:ncol(scaled_cars)]
y_train <- scaled_cars[1:25, 1, drop = FALSE]

set.seed(1)

keras_fit <-
    keras_model_sequential(input_shape = ncol(x_train))  %>%
    layer_dense(units = 1, activation = 'linear') %>%
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

v <- vetiver_model(keras_fit, "cars-keras", prototype_data = data.frame(x_train)[1,])
## pr() %>% vetiver_api(v, debug = TRUE) %>% pr_run()

library(pins)
b <- board_connect()
b %>% vetiver_pin_write(v)

vetiver_deploy_rsconnect(
    b,
    "julia.silge/cars-keras",
    predict_args = list(debug = TRUE),
    account = "julia.silge"
)


