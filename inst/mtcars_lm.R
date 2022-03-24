library(vetiver)
cars_lm <- lm(mpg ~ ., data = mtcars)
v <- vetiver_model(cars_lm, "cars_linear")

library(pins)
model_board <- board_folder(path = "/tmp/test", versioned = TRUE)
vetiver_pin_write(model_board, v)

library(plumber)
pr() %>%
    vetiver_api(v, debug = TRUE)
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(model_board, "cars_linear", file = "inst/plumber/mtcars-lm/plumber.R")
