skip_if_not_installed("plumber")
library(plumber)

test_that("default endpoint", {
    p <- pr() %>% vetiver_api(v)
    expect_equal(
        names(p$routes),
        c("logo", "metadata", "ping", "predict", "prototype")
    )
    expect_equal(
        map_chr(p$routes[-1], "verbs"),
        c(metadata = "GET", ping = "GET", predict = "POST", prototype = "GET")
    )
})

test_that("old function is deprecated", {
    expect_snapshot_error(p <- pr() %>% vetiver_pr_predict(v))
})

test_that("default endpoint via modular functions", {
    p1 <- pr() %>% vetiver_api(v)
    p2 <- pr() %>% vetiver_pr_post(v) %>% vetiver_pr_docs(v)
    expect_equal(p1$endpoints, p2$endpoints)
    expect_equal(p1$routes, p2$routes)
})

test_that("pin URL endpoint", {
    v$metadata <- list(url = "potato")
    p <- pr() %>% vetiver_api(v)
    expect_equal(
        names(p$routes),
        c("logo", "metadata", "pin-url", "ping", "predict", "prototype")
    )
    expect_equal(
        map_chr(p$routes[-1], "verbs"),
        c(metadata = "GET",
          `pin-url` = "GET",
          ping = "GET",
          predict = "POST",
          prototype = "GET")
    )
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    car_spec <- p$getApiSpec()
    post_spec <- car_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    expect_equal(post_spec$requestBody$content$`application/json`$schema$items,
                 list(type = "object",
                      properties = list(cyl = list(type = "number"),
                                        disp = list(type = "number"))))
    get_spec1 <- car_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec1$summary),
                 "Get URL of pinned vetiver model")
    get_spec2 <- car_spec$paths$`/metadata`$get
    expect_equal(as.character(get_spec2$summary),
                 "Get all metadata of pinned vetiver model")
    get_spec3 <- car_spec$paths$`/prototype`$get
    expect_equal(as.character(get_spec3$summary),
                 "Get input data prototype for vetiver model")

})

test_that("OpenAPI spec is the same for modular functions", {
    v$metadata <- list(url = "potatoes")
    p1 <- pr() %>% vetiver_api(v)
    p2 <- pr() %>% vetiver_pr_post(v) %>% vetiver_pr_docs(v)
    spec1 <- p1$getApiSpec()
    spec2 <- p2$getApiSpec()
    expect_equal(spec1, spec2)
})

test_that("OpenAPI spec for check_prototype = FALSE", {
    expect_snapshot_warning(
        p <- pr() %>% vetiver_pr_post(v, check_ptype = FALSE) %>% vetiver_pr_docs(v)
    )

    p <- pr() %>% vetiver_pr_post(v, check_prototype = FALSE) %>% vetiver_pr_docs(v)
    expect_equal(names(p$routes), c("logo", "metadata", "ping", "predict"))
    expect_equal(map_chr(p$routes[-1], "verbs"),
                 c(metadata = "GET", ping = "GET", predict = "POST"))
    car_spec <- p$getApiSpec()
    post_spec <- car_spec$paths$`/predict`$post

    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    expect_equal(names(post_spec$requestBody$content$`application/json`$schema$items),
                 c("type", "properties"))
})

test_that("OpenAPI spec for save_prototype = FALSE", {
    v1 <- vetiver_model(cars_lm, "cars1", save_prototype = FALSE)
    p <- pr() %>% vetiver_api(v1)
    expect_equal(names(p$routes), c("logo", "metadata", "ping", "predict"))
    expect_equal(map_chr(p$routes[-1], "verbs"),
                 c(metadata = "GET", ping = "GET", predict = "POST"))
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
    v <- vetiver_model(cars_lm, "cars1", save_prototype = car_ptype)
    p <- pr() %>% vetiver_api(v)
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
    expect_equal(car_spec$paths$`/prototype`$get$summary,
                 "Get input data prototype for vetiver model")

})

test_that("OpenAPI spec with additional endpoints", {
    v$metadata <- list(url = "potatoes")

    another_handler <- function(req) {
        newdata <- req$body
        sum(newdata[names(v$prototype)])
    }

    p <- pr() %>%
        vetiver_pr_post(v) %>%
        pr_post(path = "/sum", handler = another_handler) %>%
        pr_get(
            "/",
            function() "Hello World",
            ## to test Connect redirect:
            comments = "This endpoint was added to automatically redirect visitors"
        ) %>%
        vetiver_pr_docs(v)

    car_spec <- p$getApiSpec()
    expect_equal(car_spec$path$`/`, NULL)
    expect_true(all(names(car_spec$paths) %in% paste0("/", names(p$routes))))

    post_spec <- car_spec$paths$`/predict`$post
    sum_spec <- car_spec$paths$`/sum`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(names(sum_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 2 features")
    expect_equal(as.character(sum_spec$summary),
                 "Return /sum from model using 2 features")
    items <- list(type = "object",
                  properties = list(cyl = list(type = "number"),
                                    disp = list(type = "number")))
    expect_equal(post_spec$requestBody$content$`application/json`$schema$items,
                 items)
    expect_equal(sum_spec$requestBody$content$`application/json`$schema$items,
                 items)
})

test_that("debug listens to `is_interactive()`", {
    rlang::with_interactive(value = FALSE, {
        p <- pr() %>% vetiver_api(v)
        expect_equal(p$getDebug(), FALSE)
    })
    rlang::with_interactive(value = TRUE, {
        p <- pr() %>% vetiver_api(v)
        expect_equal(p$getDebug(), TRUE)
    })
})

