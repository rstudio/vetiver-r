library(tidymodels)
data(bivariate)

biv_rec <-
    recipe(Class ~ ., data = bivariate_train) %>%
    step_BoxCox(all_predictors())%>%
    step_normalize(all_predictors())

svm_spec <-
    svm_linear(mode = "classification") %>%
    set_engine("LiblineaR")

svm_fit <- workflow() %>%
    add_recipe(biv_rec) %>%
    add_model(svm_spec) %>%
    fit(bivariate_train)

library(vetiver)
v <- vetiver_model(svm_fit, "biv_svm")
v

library(pins)
model_board <- board_folder(path = "/tmp/test", versioned = TRUE)
vetiver_pin_write(model_board, v)

library(plumber)
pr() %>%
    vetiver_api(v, type = "class", debug = TRUE)
## next pipe to pr_run(port = 8088) to see visual documentation

vetiver_write_plumber(model_board, "biv_svm", file = "inst/plumber/biv-svm/plumber.R")
