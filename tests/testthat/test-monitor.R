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
            .every = 6L
        )
        expect_s3_class(res, "tbl_df")
        expect_equal(unique(res$.metric), c("rmse", "rsq", "mae"))
        expect_equal(ncol(res), 5)
        expect_equal(nrow(res), 54)
    })
})

describe("vetiver_pin_metrics()", {

    data(Chicago, package = "modeldata")
    Chicago <- dplyr::select(Chicago, ridership, date, one_of(stations))
    training_data <- dplyr::filter(Chicago, date < "2009-01-01")
    testing_data <- dplyr::filter(Chicago, date >= "2009-01-01", date < "2011-01-01")
    lm_fit <- parsnip::fit(parsnip::linear_reg(), ridership ~ ., data = training_data)

    df_metrics <-
        parsnip::augment(lm_fit, new_data = testing_data) %>%
        vetiver_compute_metrics(date, "week", ridership, .pred, .every = 4L)

    it("can initiate metrics", {
        b <- pins::board_temp()
        res <- vetiver_pin_metrics(
            df_metrics, date, b, "metrics1", initiate = TRUE
        )
        expect_equal(pins::pin_read(b, "metrics1"), res)
        expect_equal(vctrs::vec_sort(df_metrics), res)
    })
    it("can update metrics", {
        b <- pins::board_temp()
        res1 <- vetiver_pin_metrics(
            df_metrics, date, b, "metrics2", initiate = TRUE
        )
        new_metrics <- tibble::tibble(
            date = as.Date("2011-01-12"),
            n = 30,
            .metric = c("rmse", "rsq", "mae"),
            .estimator = "standard",
            .estimate = c(3.0, 0.7, 2.0)

        )
        res2 <- vetiver_pin_metrics(new_metrics, date, b, "metrics2")
        expect_equal(
            pins::pin_read(b, "metrics2"),
            vctrs::vec_rbind(res1, vctrs::vec_sort(new_metrics))
        )
    })
})


describe("vetiver_compute_metrics()", {

    data(Chicago, package = "modeldata")
    Chicago <- dplyr::select(Chicago, ridership, date, one_of(stations))
    training_data <- dplyr::filter(Chicago, date < "2009-01-01")
    testing_data <- dplyr::filter(Chicago, date >= "2009-01-01", date < "2011-01-01")
    lm_fit <- parsnip::fit(parsnip::linear_reg(), ridership ~ ., data = training_data)

    df_metrics <-
        parsnip::augment(lm_fit, new_data = testing_data) %>%
        vetiver_compute_metrics(date, "week", ridership, .pred, .every = 4L)

    it("can plot monitoring metrics", {
        p <- vetiver_plot_metrics(df_metrics, date)
        expect_s3_class(p, "ggplot")
        vdiffr::expect_doppelganger("default metrics plot", p)
    })

})
