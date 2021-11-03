library(mlr3)
library(tibble)
library(vetiver)

task = tsk("pima")
learner = lrn("classif.rpart")

learner$train(task)

v <- vetiver_model(learner, "cars_linear")
v

library(plumber)

pr() %>%
  vetiver_pr_predict(v) %>%
  pr_run(port = 8088)

library(mlr3)
library(plumber)
library(vetiver)
library(tibble)

task = tsk("pima")
newdata = as_tibble(task$data())[, task$feature_names]

endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
predict(endpoint, newdata)