library(modelops)
library(pins)
library(plumber)
model_board <- board_temp()

cars_lm <- lm(mpg ~ ., data = mtcars)

model_board %>% pin_model(cars_lm, "cars")

pr() %>%
    pr_model(model_board, "cars") %>%
    pr_run(port = 8088)
