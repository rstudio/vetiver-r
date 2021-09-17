library(modelops)
library(pins)
library(plumber)

model_board <- board_temp()
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
m <- modelops(cars_lm, "cars_linear", model_board, ptype = mtcars[20:22, 2:3])
modelops_pin_write(m)

pr() %>%
    modelops_pr_predict(m, debug = TRUE) %>%
    pr_run(port = 8088)
