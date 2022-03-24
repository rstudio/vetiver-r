library(vetiver)
library(pins)
library(plumber)

model_board <- board_folder(path = "/tmp/test", versioned = TRUE)
cars_xgb <- xgboost::xgboost(as.matrix(mtcars[,-1]),
                             mtcars$mpg,
                             nrounds = 3,
                             objective = "reg:squarederror")
v <- vetiver_model(cars_xgb, "cars_xgb")
model_board %>% vetiver_pin_write(v)

pr() %>%
    vetiver_api(v, debug = TRUE)
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(model_board, "cars_xgb", file = "inst/plumber/mtcars-xgb/plumber.R")
