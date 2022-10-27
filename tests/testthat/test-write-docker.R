b <- board_folder(path = tmp_dir)

test_that("create Dockerfile with packages", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("beepr", "caret", "stats")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with no RSPM", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("beepr", "caret")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"),
                         tmp_dir, rspm = FALSE)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with no packages", {
    skip_on_cran()
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with specific port", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("beepr", "caret")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"),
                         tmp_dir, port = 'as.numeric(Sys.getenv("PORT"))',
                         expose = FALSE)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("No sys deps", {
    skip_on_cran()
    # Data package; should always have 0 sys reqs
    reqs <- glue_sys_reqs("ggplot2movies")
    expect_length(reqs, 0)
})
