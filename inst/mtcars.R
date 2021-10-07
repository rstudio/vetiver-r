library(vetiver)
library(pins)
library(plumber)

model_board <- board_folder(path = "/tmp/test")
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear", model_board)
vetiver_pin_write(v)

pr() %>%
    vetiver_pr_predict(v, debug = TRUE) %>%
    pr_run(port = 8088)

# vetiver_write_plumber(model_board, "cars_linear", file = "plumber/mtcars/plumber.R")


