library(pins)
library(plumber)

b <- board_temp()

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
pin_model(b, cars_lm, "cars1")

test_that("default endpoint", {
    p <- pr() %>% pr_model(b, "cars1")
    ep <- p$endpoints[[1]][[1]]
    expect_equal(ep$verbs, c("POST"))
    expect_equal(ep$path, "/predict")
})
