library(modelops)
library(pins)
library(plumber)

model_board <- board_rsconnect(server = "https://colorado.rstudio.com/rsc")
m <- modelops(cars_lm, "cars_linear", model_board)

#* @plumber
function(pr) {
    pr %>% modelops_pr_predict(m)
}
