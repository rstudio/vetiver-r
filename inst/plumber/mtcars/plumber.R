## auto generate this file

library(modelops)
library(pins)
library(plumber)

b <- board_rsconnect(server = "https://colorado.rstudio.com/rsc")
m <- modelops_pin_read(b, "julia.silge/cars_linear")
stopifnot(m$metadata$version == "46968")

## or is it better to deploy with:
## m <- modelops_pin_read(b, "julia.silge/cars_linear", version = "46968")

#* @plumber
function(pr) {
    pr %>% modelops_pr_predict(m)
}
