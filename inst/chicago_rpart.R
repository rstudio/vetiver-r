library(tidymodels)
data(Chicago)

chicago_small <- Chicago %>% slice(1:365)

splits <-
    sliding_period(
        chicago_small,
        date,
        "day",
        lookback = 300,   # Each resample has 300 days for modeling
        assess_stop = 7,  # One week for performance assessment
        step = 7          # Ensure non-overlapping weeks for assessment
    )

chicago_rec <-
    recipe(ridership ~ ., data = Chicago) %>%
    step_date(date) %>%
    step_holiday(date, keep_original_cols = FALSE) %>%
    step_dummy(all_nominal_predictors()) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_predictors()) %>%
    step_pca(all_of(stations), num_comp = 4)

tree_spec <-
    decision_tree() %>%
    set_engine("rpart") %>%
    set_mode("regression")

chicago_fit <-
    workflow(chicago_rec, tree_spec) %>%
    fit(chicago_small)

library(vetiver)
v <- vetiver_model(chicago_fit, "julia.silge/chicago_ridership")
v


vetiver_pin_write(model_board, v, check_renv = TRUE)

#* -------------------------------------------------------------------------- *#

library(vetiver)
library(pins)
model_board <- board_connect()
vetiver_deploy_rsconnect(
    model_board,
    "julia.silge/chicago_ridership",
    predict_args = list(debug = TRUE),
    account = "julia.silge"
)

#* -------------------------------------------------------------------------- *#

library(plumber)
pr() %>%
    vetiver_api(v, debug = TRUE)
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(
    model_board,
    "julia.silge/chicago_ridership",
    debug = TRUE,
    file = "inst/plumber/chicago-rpart/plumber.R"
)
