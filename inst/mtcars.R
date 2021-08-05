library(modelops)
library(pins)
library(plumber)

cars_lm <- lm(mpg ~ ., data = mtcars)

pr() %>%
    pr_model(board_temp(), cars_lm, "mtcars_linear_reg", debug = TRUE) %>%
    pr_run(port = 8088)
