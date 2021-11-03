test_that("mlr3 learner description can be printed", {
  skip_if_not_installed("mlr3")

  task =  mlr3::tsk("pima")
  learner =  mlr3::lrn("classif.rpart")
  learner$train(task)

  expect_equal(vetiver_create_description(learner), glue("A mlr3 classif.rpart learner"))
})

test_that("mlr3 learners can be pinned", {
  skip_if_not_installed("mlr3")

  task =  mlr3::tsk("pima")
  learner =  mlr3::lrn("classif.rpart")
  learner$train(task)

  v <- vetiver_model(learner, "rpart_pima")
  b <- board_temp()
  vetiver_pin_write(b, v)
  pinned <- pin_read(b, "rpart_pima")

  expect_length(pinned, 3)
  expect_equal(class(pinned$model)[1], "LearnerClassifRpart")
  expect_equal(nrow(pinned$ptype), 0)
  expect_equal(names(pinned$ptype), task$feature_names)
  expect_equal(pinned$required_pkgs, c("mlr3", "rpart"))
})

test_that("learners from mlr3learners can be pinned", {
  skip_if_not_installed("mlr3")
  skip_if_not_installed("mlr3learners")

  task =  mlr3::tsk("spam")
  learner = mlr3learners::LearnerClassifXgboost$new()
  learner$train(task)

  v <- vetiver_model(learner, "logreg_spam")
  b <- board_temp()
  vetiver_pin_write(b, v)
  pinned <- pin_read(b, "logreg_spam")

  expect_length(pinned, 3)
  expect_equal(class(pinned$model)[1], "LearnerClassifXgboost")
  expect_equal(nrow(pinned$ptype), 0)
  expect_equal(names(pinned$ptype), task$feature_names)
  expect_equal(pinned$required_pkgs, c("mlr3", "mlr3learners", "xgboost"))
})
