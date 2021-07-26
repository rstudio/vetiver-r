library(modelops)
library(pins)
library(plumber)

model_board <- board_rsconnect()

#* @plumber
function(pr) {
    pr %>%
        pr_model(model_board, "julia.silge/mtcars_linear_reg")
}
