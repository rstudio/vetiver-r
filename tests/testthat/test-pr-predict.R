library(pins)
library(plumber)

b <- board_temp()

cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
m <- modelops(cars_lm, "cars1", b)

test_that("default endpoint", {
    p <- pr() %>% modelops_pr_predict(m)
    ep <- p$endpoints[[1]][[1]]
    expect_equal(ep$verbs, c("POST"))
    expect_equal(ep$path, "/predict")
})

test_that("pin URL endpoint", {
    m$metadata <- list(url = "potato")
    p <- pr() %>% modelops_pr_predict(m)
    ep_pin <- p$endpoints[[1]][[1]]
    expect_equal(ep_pin$verbs, c("GET"))
    expect_equal(ep_pin$path, "/pin-url")
    ep_predict <- p$endpoints[[1]][[2]]
    expect_equal(ep_predict$verbs, c("POST"))
    expect_equal(ep_predict$path, "/predict")
})

test_that("default OpenAPI spec", {
    m$metadata <- list(url = "potatoes")
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
    get_spec <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned modelops object")

})

test_that("OpenAPI spec with custom ptype", {
    car_ptype <- mtcars[15:16, 2:3]
    m <- modelops(cars_lm, "cars1", b, ptype = car_ptype)
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
    expect_equal(post_spec$requestBody$content$`application/json`$schema$example,
                 purrr::transpose(car_ptype))


})

