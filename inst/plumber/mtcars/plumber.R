## auto generate this file

library(modelops)
library(pins)
library(plumber)

model_board <- board_rsconnect(server = "https://colorado.rstudio.com/rsc")
m <- model_board %>% modelops_pin_read("julia.silge/cars_linear")
stopifnot(m$metadata$version == "46968")

#* @plumber
function(pr) {
    pr %>% modelops_pr_predict(m)
}
