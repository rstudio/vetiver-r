skip_if_not_installed("plumber")
b <- board_folder(path = tmp_dir)

test_that("create Dockerfile with packages", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("pingr", "caret", "stats")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir)
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with 'additional' packages", {
    skip_on_cran()
    local_mocked_bindings(
        version_name = function(metadata) "20120304T050607Z-xxxxx",
        .package = "pins"
    )
    v$metadata$required_pkgs <- c("pingr", "caret", "stats")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = file.path(tmp_dir, "plumber.R"))
    vetiver_write_docker(v, file.path(tmp_dir, "plumber.R"), tmp_dir,
                         additional_pkgs = c("caret", "ggplot2"))
    expect_true(fs::file_exists(fs::path(tmp_dir, "vetiver_renv.lock")))
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create Dockerfile with no RSPM", {
    skip_on_cran()
    local_mocked_bindings(
        version_name = function(metadata) "20120304T050607Z-yyyyy",
        .package = "pins"
    )
    v$metadata$required_pkgs <- c("pingr", "caret")
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
    v$metadata$required_pkgs <- c("pingr", "caret")
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

test_that("create all files needed for Docker", {
    skip_on_cran()
    v$metadata$required_pkgs <- c("pingr", "caret")
    vetiver_pin_write(b, v)
    vetiver_prepare_docker(b, "cars1", path = tmp_dir,
                           predict_args = list(path = "cars"),
                           docker_args = list(rspm = FALSE))

    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "plumber.R")), sep = "\n"),
        transform = redact_vetiver
    )
    expect_snapshot(
        cat(readr::read_lines(file.path(tmp_dir, "Dockerfile")), sep = "\n"),
        transform = redact_vetiver
    )
})
