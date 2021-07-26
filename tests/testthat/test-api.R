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

test_that("OpenAPI spec", {
    p <- pr() %>% pr_model(b, "cars1")
    car_spec <- p$getApiSpec()
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    expect_equal(post_spec$requestBody$content$`application/json`$schema$items,
                 list(type = "object",
                      properties = list(cyl = list(type = "number"),
                                        disp = list(type = "number"))))
})

