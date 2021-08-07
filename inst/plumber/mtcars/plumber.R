library(modelops)
library(pins)
library(plumber)

model_board <- board_rsconnect(server = "https://colorado.rstudio.com/rsc")
m <- model_board %>% pin_read("julia.silge/cars_linear")

#* @plumber
function(pr) {
    pr %>% modelops_pr_predict(m)
}
