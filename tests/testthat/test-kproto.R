skip_if_not_installed("clustMixType")
skip_if_not_installed("plumber")

library(plumber)

data(crickets, package = "modeldata")
## this model does not work with tibble input:
crickets <- as.data.frame(crickets)

set.seed(123)
kp_fit <- clustMixType::kproto(crickets, k = 3, verbose = FALSE)
v <- vetiver_model(kp_fit, "kproto-example")

test_that("can print kproto model", {
    expect_snapshot(v)
})

test_that("can predict kproto model", {
    ## prediction is broken for single observation

    predicted_clusters <- predict(v, crickets[5:6,])
    expect_equal(predicted_clusters$cluster, c(1, 1))
})

test_that("can pin a kproto model", {
    b <- pins::board_temp()
    vetiver_pin_write(b, v)
    pinned <- pins::pin_read(b, "kproto-example")
    expect_equal(
        pinned,
        list(
            model = vetiver_prepare_model(kp_fit),
            prototype = vctrs::vec_ptype(tibble::as_tibble(crickets)),
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
                 "A k-prototypes clustering model (3 clusters)")
    post_spec <- api_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 3 features")
    get_spec <- api_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for kproto", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "kproto-example", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})
