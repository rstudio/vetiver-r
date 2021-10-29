library(plumber)
cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
v <- vetiver_model(cars_lm, "cars1")

test_that("default endpoint", {
    p <- pr() %>% vetiver_pr_predict(v)
    ep <- p$endpoints[[1]][[1]]
    expect_equal(ep$verbs, c("POST"))
    expect_equal(ep$path, "/predict")
})

test_that("pin URL endpoint", {
    v$metadata <- list(url = "potato")
    p <- pr() %>% vetiver_pr_predict(v)
    ep_pin <- p$endpoints[[1]][[1]]
    expect_equal(ep_pin$verbs, c("GET"))
    expect_equal(ep_pin$path, "/pin-url")
    ep_predict <- p$endpoints[[1]][[2]]
    expect_equal(ep_predict$verbs, c("POST"))
    expect_equal(ep_predict$path, "/predict")
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_pr_predict(v)
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
                 "Get URL of pinned vetiver model")

})

test_that("OpenAPI spec for save_ptype = FALSE", {
  v1 <- vetiver_model(cars_lm, "cars1", save_ptype = FALSE)
  p <- pr() %>% vetiver_pr_predict(v1)
  ep <- p$endpoints[[1]][[1]]
  expect_equal(ep$verbs, c("POST"))
  expect_equal(ep$path, "/predict")
  car_spec <- p$getApiSpec()
  post_spec <- car_spec$paths$`/predict`$post
  expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
  expect_equal(as.character(post_spec$summary),
               "Return predictions from model")
  expect_equal(names(post_spec$requestBody$content$`application/json`$schema$items),
               c("type", "properties"))

})

test_that("OpenAPI spec with custom ptype", {
    car_ptype <- mtcars[15:16, 2:3]
    v <- vetiver_model(cars_lm, "cars1", b, save_ptype = car_ptype)
    p <- pr() %>% vetiver_pr_predict(v)
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


test_that("debug listens to `is_interactive()`", {
  rlang::with_interactive(value = FALSE, {
    p <- pr() %>% vetiver_pr_predict(v)
    expect_equal(p$getDebug(), FALSE)
  })
  rlang::with_interactive(value = TRUE, {
    p <- pr() %>% vetiver_pr_predict(v)
    expect_equal(p$getDebug(), TRUE)
  })
})
