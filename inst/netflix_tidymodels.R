library(tidymodels)
library(textrecipes)
library(themis)

url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-20/netflix_titles.csv"

netflix_types <- readr::read_csv(url) %>%
    select(type, description)

set.seed(123)
netflix_split <- netflix_types %>%
    select(type, description) %>%
    initial_split(strata = type)

netflix_train <- training(netflix_split)
netflix_test <- testing(netflix_split)

netflix_rec <- recipe(type ~ description, data = netflix_train) %>%
    step_tokenize(description) %>%
    step_tokenfilter(description, max_tokens = 1e3) %>%
    step_tfidf(description) %>%
    step_normalize(all_numeric_predictors()) %>%
    step_smote(type)

svm_spec <- svm_linear() %>%
    set_mode("classification") %>%
    set_engine("LiblineaR")

netflix_fit <-
    workflow(netflix_rec, svm_spec) %>%
    fit(netflix_train)

library(vetiver)
v <- vetiver_model(netflix_fit, "netflix_descriptions")
v

library(pins)
model_board <- board_connect()
vetiver_pin_write(model_board, v)

library(plumber)
pr() %>%
    vetiver_api(v, debug = TRUE)
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(
    model_board,
    "julia.silge/netflix_descriptions",
    debug = TRUE,
    file = "inst/plumber/netflix-descriptions/plumber.R"
)

