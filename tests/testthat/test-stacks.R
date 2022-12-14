skip_on_cran()
skip_if_not_installed("stacks")
skip_if_not_installed("plumber")

library(plumber)
library(stacks)

data("tree_frogs", package = "stacks")
tree_test <- tree_frogs %>%
    dplyr::select(-hatched, -latency, -clutch)

frog_reg <-
    stacks() %>%
    add_candidates(reg_res_lr) %>%
    add_candidates(reg_res_sp) %>%
    blend_predictions(penalty = 20) %>%
    fit_members()

v <- vetiver_model(frog_reg, "frog-stack")

test_that("can print stacks model", {
    expect_snapshot(v)
})

test_that("can predict stacks model", {
    preds <- predict(v, tree_test[2:10,])
    expect_s3_class(preds, "tbl_df")
    expect_equal(mean(preds$.pred), 142, tolerance = 1)
})

test_that("can pin a stacks model", {
    b <- board_temp()
    vetiver_pin_write(b, v)
    pinned <- pin_read(b, "frog-stack")
    expect_equal(
        pinned,
        list(
            model = bundle::bundle(butcher::butcher(frog_reg)),
            prototype = vctrs::vec_ptype(tree_test),
            required_pkgs = c("glmnet", "parsnip", "recipes", "stacks", "stats", "workflows")
        )
    )
})

test_that("default OpenAPI spec", {
    v$metadata <- list(url = "potatoes")
    p <- pr() %>% vetiver_api(v)
    frog_spec <- p$getApiSpec()
    expect_equal(frog_spec$info$description,
                 "A regression stacked ensemble with 3 members")
    post_spec <- frog_spec$paths$`/predict`$post
    expect_equal(names(post_spec), c("summary", "requestBody", "responses"))
    expect_equal(as.character(post_spec$summary),
                 "Return predictions from model using 4 features")
    get_spec <- frog_spec$paths$`/pin-url`$get
    expect_equal(as.character(get_spec$summary),
                 "Get URL of pinned vetiver model")

})

test_that("create plumber.R for stacks", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    vetiver_pin_write(b, v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "frog-stack", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

