library(vetiver)
library(pins)
library(plumber)

cars_rf <- ranger::ranger(mpg ~ ., data = mtcars, quantreg = TRUE)
v <- vetiver_model(cars_rf, "cars_ranger", prototype_data = mtcars[,-1])

model_board <- board_folder(path = "/tmp/test")
vetiver_pin_write(model_board, v)

pr() %>% vetiver_api(v, debug = TRUE, type = "quantiles")
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(
    model_board,
    "cars_ranger",
    debug = TRUE,
    type = "quantiles",
    file = "inst/plumber/mtcars-ranger/plumber.R"
)
