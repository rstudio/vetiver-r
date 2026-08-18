library(mlr3)
library(vetiver)
library(plumber)

task <- tsk("penguins")
learner <- lrn("classif.rpart")

learner$train(task)

v <- vetiver_model(learner, "penguins_rpart")
v

pr() |>
  vetiver_api(v) |>
  pr_run(port = 8088)

library(mlr3)
library(plumber)
library(vetiver)
library(tibble)

task <- tsk("penguins")
newdata <- as_tibble(task$data())[, task$feature_names]

endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
predict(endpoint, newdata)
