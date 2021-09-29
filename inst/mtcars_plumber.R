library(modelops)
library(pins)
library(plumber)

b <- board_temp(versioned = TRUE)
cars_lm <- lm(mpg ~ ., data = mtcars)
m <- modelops(cars_lm, "cars_linear", b)
m$metadata$required_pkgs <- c("beepr", "janeaustenr")
modelops_pin_write(m)

modelops_write_plumber(b, "cars_linear")

