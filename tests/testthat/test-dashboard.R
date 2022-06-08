test_that("templates exist", {
    expect_equal(
        rmarkdown::available_templates("vetiver"),
        c("vetiver_dashboard", "vetiver_model_card")
    )
})

describe("vetiver_dashboard()", {

    # don't run on cran because pandoc is required
    skip_on_cran()
    skip_if_not_installed("flexdashboard")

    rmd <- withr::local_tempfile(fileext = ".Rmd")
    html <- withr::local_tempfile(fileext = ".html")
    path <- expect_invisible(rmarkdown::draft(
        rmd,
        template = "vetiver_dashboard",
        package = "vetiver",
        create_dir = FALSE,
        edit = FALSE
    ))

    it("can create dashboard", {
        expect_identical(rmd, path)
        expect_true(file.exists(rmd))
    })

    it("can render dashboard", {
        output_format <- vetiver_dashboard(pins::board_rsconnect(), "julia.silge/hotel_rf")
        rmarkdown::render(rmd, output_format = output_format, output_file = html)
        expect_true(file.exists(html))
    })

})