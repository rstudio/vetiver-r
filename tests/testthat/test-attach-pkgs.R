test_that("can attach pkgs", {
    skip_on_cran()
    expect_error(attach_pkgs(c("knitr", "readr")), NA)
})

test_that("can fail on a single pkg", {
    skip_on_cran()
    expect_snapshot_error(attach_pkgs(c("potato")))
})

test_that("can fail on multiple pkgs", {
    skip_on_cran()
    expect_snapshot_error(attach_pkgs(c("potato", "bloopy")))
    expect_snapshot_error(attach_pkgs(c("potato", "readr")))
})
