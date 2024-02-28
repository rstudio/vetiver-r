skip_if_not_installed("plumber")

test_that("create plumber.R with no packages", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    local_mocked_bindings(version_name = function(metadata) "20130104T050607Z-xxxxx", .package = "pins")
    tmp <- tempfile()
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R for complicated board", {
    skip_on_cran()
    b <- pins::new_board(
        "pins_board_s3",
        api = 1L,
        cache = board_cache_path("pins"),
        versioned = FALSE,
        bucket = "foo",
        svc = list(.internal =
                       list(config = list(credentials = list(creds = list(profile = 4)),
                                          region = 6, endpoint = 8)))
    )
    local_mocked_bindings(vetiver_pin_read = function(board, name, version) v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R for URL board", {
    skip_on_cran()
    b <- pins::new_board(
        "pins_board_url",
        api = 1L,
        cache = board_cache_path("pins"),
        versioned = FALSE,
        bucket = "foo",
        urls = c(foo = "foo", bar = "bar", baz = "baz")
    )
    local_mocked_bindings(vetiver_pin_read = function(board, name, version) v)
    tmp <- tempfile()
    vetiver_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R with packages", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    local_mocked_bindings(version_name = function(metadata) "20130204T050607Z-xxxxx", .package = "pins")
    tmp <- tempfile()
    v$metadata$required_pkgs <- c("beepr", "janeaustenr")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R with extra infra packages", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    local_mocked_bindings(version_name = function(metadata) "20130204T050607Z-xyxy", .package = "pins")
    tmp <- tempfile()
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = tmp, additional_pkgs = c("beepr", "janeaustenr"))
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R with rsconnect = FALSE", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    local_mocked_bindings(version_name = function(metadata) "20130304T050607Z-xxxxx", .package = "pins")
    tmp <- tempfile()
    v$metadata$required_pkgs <- c("beepr", "janeaustenr")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1", file = tmp, rsconnect = FALSE)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})

test_that("create plumber.R with args in dots", {
    skip_on_cran()
    b <- board_folder(path = tmp_dir)
    local_mocked_bindings(version_name = function(metadata) "20130404T050607Z-xxxxx", .package = "pins")
    tmp <- tempfile()
    v$metadata$required_pkgs <- c("beepr", "janeaustenr")
    vetiver_pin_write(b, v)
    vetiver_write_plumber(b, "cars1",
                          debug = TRUE, endpoint = "/predict2", type = "numeric",
                          file = tmp)
    expect_snapshot(
        cat(readr::read_lines(tmp), sep = "\n"),
        transform = redact_vetiver
    )
})
