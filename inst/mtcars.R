library(modelops)
library(pins)
library(plumber)

model_board <- board_temp()
cars_lm <- lm(mpg ~ ., data = mtcars)
m <- modelops(cars_lm, "cars_linear", model_board)

pr() %>%
    modelops_pin_router(m) %>%
    pr_run(port = 8088)
