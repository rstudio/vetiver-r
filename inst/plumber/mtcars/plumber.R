library(modelops)
library(pins)
library(plumber)

## modelops object with `board_rsconnect()`
m <- readr::read_rds("modelops_cars_linear.rds")

#* @plumber
function(pr) {
    pr %>% modelops_pin_router(m)
}
