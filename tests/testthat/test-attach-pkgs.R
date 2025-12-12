test_that("can attach pkgs", {
  skip_on_cran()
  expect_snapshot(attach_pkgs(c("knitr", "readr")))
})

test_that("can fail on a single pkg", {
  skip_on_cran()
  expect_snapshot(attach_pkgs(c("potato")), error = TRUE)
})

test_that("can fail on multiple pkgs", {
  skip_on_cran()
  expect_snapshot(attach_pkgs(c("potato", "bloopy")), error = TRUE)
  expect_snapshot(attach_pkgs(c("potato", "readr")), error = TRUE)
})
