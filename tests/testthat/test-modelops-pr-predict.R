library(pins)
library(plumber)

b <- board_temp()

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
m <- modelops(cars_lm, "cars1", b)
modelops_pin_write(m)

test_that("default endpoint", {
    p <- pr() %>% modelops_pr_predict(m)
    ep <- p$endpoints[[1]][[1]]
    expect_equal(ep$verbs, c("POST"))
    expect_equal(ep$path, "/predict")
})

test_that("default endpoint", {
    m2 <- modelops(cars_lm, "cars2", b)
    expect_error(
        pr() %>% modelops_pr_predict(m2),
        "Model `cars2` not found on pin board"
    )

})

test_that("OpenAPI spec", {
    p <- pr() %>% modelops_pr_predict(m)
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

