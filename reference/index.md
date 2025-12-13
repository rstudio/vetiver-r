# Package index

## Handling vetiver objects

A
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
collects the information needed to store, version, and deploy a trained
model.

- [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  [`new_vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  : Create a vetiver object for deployment of a trained model

- [`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md)
  [`vetiver_pin_read()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_write.md)
  : Read and write a trained model to a board of models

- [`vetiver_api()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  [`vetiver_pr_post()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  [`vetiver_pr_docs()`](https://rstudio.github.io/vetiver-r/reference/vetiver_api.md)
  :

  Create a Plumber API to predict with a deployable
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  object

- [`vetiver_write_plumber()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_plumber.md)
  : Write a deployable Plumber file for a vetiver model

- [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_write_docker.md)
  : Write a Dockerfile for a vetiver model

- [`vetiver_prepare_docker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_prepare_docker.md)
  : Generate files necessary to build a Docker container for a vetiver
  model

- [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/reference/vetiver_endpoint.md)
  : Create a model API endpoint object for prediction

- [`predict(`*`<vetiver_endpoint>`*`)`](https://rstudio.github.io/vetiver-r/reference/predict.vetiver_endpoint.md)
  : Post new data to a deployed model API endpoint and return
  predictions

- [`augment(`*`<vetiver_endpoint>`*`)`](https://rstudio.github.io/vetiver-r/reference/augment.vetiver_endpoint.md)
  : Post new data to a deployed model API endpoint and augment with
  predictions

## Posit Connect

Deploy your vetiver model to Posit Connect.

- [`vetiver_deploy_rsconnect()`](https://rstudio.github.io/vetiver-r/reference/vetiver_deploy_rsconnect.md)
  : Deploy a vetiver model API to Posit Connect
- [`vetiver_create_rsconnect_bundle()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_rsconnect_bundle.md)
  : Create an Posit Connect bundle for a vetiver model API

## SageMaker

Deploy your vetiver model to Amazon SageMaker.

- [`vetiver_deploy_sagemaker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_deploy_sagemaker.md)
  : Deploy a vetiver model API to Amazon SageMaker
- [`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/reference/vetiver_endpoint_sagemaker.md)
  : Create a SageMaker model API endpoint object for prediction
- [`predict(`*`<vetiver_endpoint_sagemaker>`*`)`](https://rstudio.github.io/vetiver-r/reference/predict.vetiver_endpoint_sagemaker.md)
  : Post new data to a deployed SageMaker model endpoint and return
  predictions
- [`augment(`*`<vetiver_endpoint_sagemaker>`*`)`](https://rstudio.github.io/vetiver-r/reference/augment.vetiver_endpoint_sagemaker.md)
  : Post new data to a deployed SageMaker model endpoint and augment
  with predictions
- [`vetiver_sm_build()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  [`vetiver_sm_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  [`vetiver_sm_endpoint()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_build.md)
  : Deploy a vetiver model API to Amazon SageMaker with modular
  functions
- [`vetiver_sm_delete()`](https://rstudio.github.io/vetiver-r/reference/vetiver_sm_delete.md)
  : Delete Amazon SageMaker model, endpoint, and endpoint configuration

## Monitoring deployed models

Monitor a deployed
[`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
with a dashboard.

- [`vetiver_compute_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_compute_metrics.md)
  : Aggregate model metrics over time for monitoring
- [`vetiver_pin_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_pin_metrics.md)
  : Update model metrics over time for monitoring
- [`vetiver_plot_metrics()`](https://rstudio.github.io/vetiver-r/reference/vetiver_plot_metrics.md)
  : Plot model metrics over time for monitoring
- [`vetiver_dashboard()`](https://rstudio.github.io/vetiver-r/reference/vetiver_dashboard.md)
  [`get_vetiver_dashboard_pins()`](https://rstudio.github.io/vetiver-r/reference/vetiver_dashboard.md)
  [`pin_example_kc_housing_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_dashboard.md)
  : R Markdown format for model monitoring dashboards

## Developer functions

These functions are helpful for developers extending vetiver for other
types of models.

- [`api_spec()`](https://rstudio.github.io/vetiver-r/reference/api_spec.md)
  [`glue_spec_summary()`](https://rstudio.github.io/vetiver-r/reference/api_spec.md)
  : Update the OpenAPI specification using model metadata

- [`attach_pkgs()`](https://rstudio.github.io/vetiver-r/reference/attach_pkgs.md)
  [`load_pkgs()`](https://rstudio.github.io/vetiver-r/reference/attach_pkgs.md)
  : Fully attach or load packages for making model predictions

- [`handler_startup()`](https://rstudio.github.io/vetiver-r/reference/handler_startup.md)
  [`handler_predict()`](https://rstudio.github.io/vetiver-r/reference/handler_startup.md)
  : Model handler functions for API endpoint

- [`map_request_body()`](https://rstudio.github.io/vetiver-r/reference/map_request_body.md)
  : Identify data types for each column in an input data prototype

- [`vetiver_create_description()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_description.md)
  [`vetiver_prepare_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_description.md)
  : Model constructor methods

- [`vetiver_meta()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_meta.md)
  [`vetiver_create_meta()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_meta.md)
  :

  Metadata constructors for
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/reference/vetiver_model.md)
  object

- [`vetiver_ptype()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_ptype.md)
  [`vetiver_create_ptype()`](https://rstudio.github.io/vetiver-r/reference/vetiver_create_ptype.md)
  : Create a vetiver input data prototype

- [`vetiver_type_convert()`](https://rstudio.github.io/vetiver-r/reference/vetiver_type_convert.md)
  : Convert new data at prediction time using input data prototype
