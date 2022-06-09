skip_if_not_installed("modeldata")
skip_if_not_installed("dplyr")
skip_if_not_installed("parsnip")
skip_if_not_installed("slider")
skip_if_not_installed("yardstick")

describe("vetiver_compute_metrics()", {

    data(Chicago, package = "modeldata")
    Chicago <- dplyr::select(Chicago, ridership, date, one_of(stations))
    training_data <- dplyr::filter(Chicago, date < "2009-01-01")
    testing_data <- dplyr::filter(Chicago, date >= "2009-01-01", date < "2011-01-01")
    lm_fit <- parsnip::fit(parsnip::linear_reg(), ridership ~ ., data = training_data)
    lm_aug <- parsnip::augment(lm_fit, new_data = testing_data)

    it("can compute default metrics", {
        res <- vetiver_compute_metrics(
            lm_aug,
            date, "month",
            ridership, .pred
        )
        expect_s3_class(res, "tbl_df")
        expect_equal(unique(res$.metric), c("rmse", "rsq", "mae"))
        expect_equal(ncol(res), 5)
        expect_equal(nrow(res), 72)
    })
    it("can compute custom metrics", {
        res <- vetiver_compute_metrics(
            lm_aug,
            date, "month",
            ridership, .pred,
            metric_set = yardstick::metric_set(yardstick::rmse, yardstick::mape)
        )
        expect_s3_class(res, "tbl_df")
        expect_equal(unique(res$.metric), c("rmse", "mape"))
        expect_equal(ncol(res), 5)
        expect_equal(nrow(res), 48)
    })
    it("can compute rolling metrics", {
        res <- vetiver_compute_metrics(
            lm_aug,
            date, "week",
            ridership, .pred,
            every = 6L
        )
        expect_s3_class(res, "tbl_df")
        expect_equal(unique(res$.metric), c("rmse", "rsq", "mae"))
        expect_equal(ncol(res), 5)
        expect_equal(nrow(res), 54)
    })
})

describe("vetiver_pin_metrics()", {

    skip_if_not_installed("vdiffr")
    data(Chicago, package = "modeldata")
    Chicago <- dplyr::select(Chicago, ridership, date, one_of(stations))
    training_data <- dplyr::filter(Chicago, date < "2009-01-01")
    testing_data <- dplyr::filter(Chicago, date >= "2009-01-01", date < "2011-01-01")
    lm_fit <- parsnip::fit(parsnip::linear_reg(), ridership ~ ., data = training_data)

    df_metrics <-
        parsnip::augment(lm_fit, new_data = testing_data) %>%
        vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)

    it("fails without existing pin", {
        b <- pins::board_temp()
        expect_snapshot_error(
            vetiver_pin_metrics(b, df_metrics, "metrics1", overwrite = TRUE)
        )
    })
    it("fails with `overwrite = FALSE`", {
        b <- pins::board_temp()
        pins::pin_write(b, df_metrics, "metrics2")
        expect_snapshot_error(
            vetiver_pin_metrics(b, df_metrics, "metrics2")
        )
    })
    it("can update metrics", {
        b <- pins::board_temp()
        pins::pin_write(b, df_metrics, "metrics3")

        new_metrics <- tibble::tibble(
            .index = as.Date("2011-01-12"),
            n = 30,
            .metric = c("rmse", "rsq", "mae"),
            .estimator = "standard",
            .estimate = c(3.0, 0.7, 2.0)

        )
        res2 <- vetiver_pin_metrics(b, new_metrics, "metrics3", overwrite = TRUE)
        expect_equal(
            pins::pin_read(b, "metrics3"),
            dplyr::arrange(vctrs::vec_rbind(df_metrics, new_metrics), .index)
        )
    })
})


describe("vetiver_plot_metrics()", {

    data(Chicago, package = "modeldata")
    Chicago <- dplyr::select(Chicago, ridership, date, one_of(stations))
    training_data <- dplyr::filter(Chicago, date < "2009-01-01")
    testing_data <- dplyr::filter(Chicago, date >= "2009-01-01", date < "2011-01-01")
    lm_fit <- parsnip::fit(parsnip::linear_reg(), ridership ~ ., data = training_data)

    df_metrics <-
        parsnip::augment(lm_fit, new_data = testing_data) %>%
        vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)

    it("can plot monitoring metrics", {
        p <- vetiver_plot_metrics(df_metrics)
        expect_s3_class(p, "ggplot")
        vdiffr::expect_doppelganger("default metrics plot", p)
    })

})
