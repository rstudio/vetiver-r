skip_if_not_installed("rsconnect")

describe("create rsconnect bundle", {
    tar_file <- fs::file_temp(pattern = "bundle", tmp_dir = tmp_dir, ext = ".tar.gz")

    b <- board_folder(path = tmp_dir)
    cars_lm <- lm(mpg ~ cyl + disp, data = mtcars)
    v <- vetiver_model(cars_lm, "cars1")
    vetiver_pin_write(b, v)
    bundle <- vetiver_create_rsconnect_bundle(b, "cars1", filename = tar_file)

    it("can create tar file", {
        expect_identical(tar_file, bundle)
        expect_true(file.exists(tar_file))
    })

    it("contains correct plumber file", {
        utils::untar(bundle, "plumber.R", exdir = tmp_dir)
        expect_snapshot(
            cat(readr::read_lines(fs::path(tmp_dir, "plumber.R")), sep = "\n"),
            transform = redact_vetiver
        )
    })

})
