skip_if_not_installed("clustMixType")
skip_if_not_installed("plumber")

library(plumber)

get_toy_data <- function() {
    # example toy data taken from clustMixType::kproto
    n   <- 100
    prb <- 0.9
    muk <- 1.5

    clusid <- rep(1:4, each = n)

    x1 <- sample(c("A","B"), 2*n, replace = TRUE, prob = c(prb, 1-prb))
    x1 <- c(x1, sample(c("A","B"), 2*n, replace = TRUE, prob = c(1-prb, prb)))
    x1 <- as.factor(x1)

    x2 <- sample(c("A","B"), 2*n, replace = TRUE, prob = c(prb, 1-prb))
    x2 <- c(x2, sample(c("A","B"), 2*n, replace = TRUE, prob = c(1-prb, prb)))
    x2 <- as.factor(x2)

    x3 <- c(rnorm(n, mean = -muk), rnorm(n, mean = muk), rnorm(n, mean = -muk), rnorm(n, mean = muk))
    x4 <- c(rnorm(n, mean = -muk), rnorm(n, mean = muk), rnorm(n, mean = -muk), rnorm(n, mean = muk))

    data.frame(x1,x2,x3,x4)
}

set.seed(123)
toy_data <- get_toy_data()
kproto_model <- clustMixType::kproto(x = toy_data,
                                     k=2,
                                     iter.max = 1000,
                                     nstart = 10,
                                     lambda = clustMixType::lambdaest(x = toy_data,
                                                                      num.method = 1,
                                                                      fac.method = 1),
                                     verbose = FALSE)
v <- vetiver_model(kproto_model, "kproto_example")

test_that("can print kproto model", {
    expect_snapshot(v)
})

test_that("can predict kproto model", {
    predicted_clusters <- predict(v, toy_data)
    expect_equal(length(predicted_clusters$cluster), NROW(toy_data))
    pred_dist <- table(predicted_clusters$cluster) %>% as.data.frame()
    expect_equal(min(pred_dist$Freq / sum(pred_dist$Freq)), 0.4975, tolerance = 0.1)
})

test_that("can pin a kproto model", {
    b <- pins::board_temp()
    vetiver_pin_write(b, v)
    pinned <- pins::pin_read(b, "kproto_example")
    expect_equal(
        pinned,
        list(
            model = vetiver_prepare_model(kproto_model),
            ptype = vctrs::vec_slice(tibble::as_tibble(toy_data), 0),
            required_pkgs = c("clustMixType")
        )
    )
})

test_that("default endpoint for kproto", {
    p <- plumber::pr() %>% vetiver_api(v)
    p_routes <- p$routes[-1]
    expect_equal(names(p_routes), c("ping", "predict"))
    expect_equal(purrr::map_chr(p_routes, "verbs"),
                 c(ping = "GET", predict = "POST"))
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    api_spec <- p$getApiSpec()
    expect_equal(api_spec$info$description,
                 "A k-prototypes clustering model")
    post_spec <- api_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 4 features")
    get_spec <- api_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for kproto", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "kproto_example", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})
