# Changelog

## vetiver (development version)

## vetiver 0.2.7

CRAN release: 2025-12-13

- Updated to support all versions of xgboost
  ([\#306](https://github.com/rstudio/vetiver-r/issues/306)).

## vetiver 0.2.6

CRAN release: 2025-10-28

- Added new `additional_pkgs` argument for writing plumber files
  ([\#271](https://github.com/rstudio/vetiver-r/issues/271)).

- Updated to use recipes’ new ability to provide input data prototype
  ([\#287](https://github.com/rstudio/vetiver-r/issues/287)).

- Added support for probably
  ([\#294](https://github.com/rstudio/vetiver-r/issues/294)).

## vetiver 0.2.5

CRAN release: 2023-11-16

- Fixed bug in generating plumber files
  ([\#257](https://github.com/rstudio/vetiver-r/issues/257)).

## vetiver 0.2.4

CRAN release: 2023-09-12

- Fixed how plumber files are generated for
  [`board_url()`](https://pins.rstudio.com/reference/board_url.html)
  ([\#241](https://github.com/rstudio/vetiver-r/issues/241)).

## vetiver 0.2.3

CRAN release: 2023-08-14

- Updated test involving renv and rsconnect
  ([\#230](https://github.com/rstudio/vetiver-r/issues/230)).

## vetiver 0.2.2

CRAN release: 2023-07-03

- Fixed a bug in where
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_docker.md)
  writes the renv lockfile
  ([\#212](https://github.com/rstudio/vetiver-r/issues/212)).

- Added new `/prototype` GET endpoint for a model’s input data prototype
  ([\#220](https://github.com/rstudio/vetiver-r/issues/220)).

## vetiver 0.2.1

CRAN release: 2023-05-16

- Added support for keras
  ([\#164](https://github.com/rstudio/vetiver-r/issues/164)), recipes
  ([\#179](https://github.com/rstudio/vetiver-r/issues/179)), and luz
  ([\#187](https://github.com/rstudio/vetiver-r/issues/187),
  [@dfalbel](https://github.com/dfalbel)).

- Moved where `required_pkgs` metadata is stored remotely, from the
  binary blob to plain text YAML
  ([\#176](https://github.com/rstudio/vetiver-r/issues/176)).

- Added an optional renv lockfile that can be stored remotely in model
  metadata, with a new `check_renv` argument for reading/writing
  ([\#154](https://github.com/rstudio/vetiver-r/issues/154),
  [\#192](https://github.com/rstudio/vetiver-r/issues/192)).

- Exposed a new `base_image` argument for creating Dockerfiles
  ([\#182](https://github.com/rstudio/vetiver-r/issues/182)).

- Added new
  [`vetiver_deploy_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_sagemaker.md)
  function plus
  [`vetiver_endpoint_sagemaker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint_sagemaker.md)
  and other needed functionality for deploying on Amazon SageMaker
  ([\#186](https://github.com/rstudio/vetiver-r/issues/186),
  [@DyfanJones](https://github.com/DyfanJones)).

- Added new additional GET endpoint for model `/metadata`
  ([\#194](https://github.com/rstudio/vetiver-r/issues/194)).

## vetiver 0.2.0

CRAN release: 2023-01-26

### Breaking changes

- The arguments for dealing with a model’s input data prototype have
  changed from using `ptype` to using `prototype`
  ([\#166](https://github.com/rstudio/vetiver-r/issues/166)):
  - In
    [`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md),
    now use `save_prototype`.
  - In
    [`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md),
    now use `check_prototype`.

### Other improvements

- Added support for k-Prototypes clustering from clustMixType
  ([\#163](https://github.com/rstudio/vetiver-r/issues/163), thanks to
  [@galen-ft](https://github.com/galen-ft)).

- Now vendor renv directly in package
  ([\#157](https://github.com/rstudio/vetiver-r/issues/157)).

- Fixed how
  [`vetiver_ptype()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_ptype.md)
  finds predictors for models ([`lm()`](https://rdrr.io/r/stats/lm.html)
  and [`glm()`](https://rdrr.io/r/stats/glm.html)) with interactions
  ([\#160](https://github.com/rstudio/vetiver-r/issues/160)).

- New argument added to
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_docker.md)
  to pass in additional packages to be installed, such as
  `required_pkgs(board)`
  ([\#159](https://github.com/rstudio/vetiver-r/issues/159)).

- New function
  [`vetiver_prepare_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_prepare_docker.md)
  creates all necessary files to deploy a basic vetiver model via Docker
  ([\#165](https://github.com/rstudio/vetiver-r/issues/165)).

- Fixed a bug in handling all-`NA` columns when predicting on a
  [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md)
  ([\#169](https://github.com/rstudio/vetiver-r/issues/169)).

## vetiver 0.1.8

CRAN release: 2022-09-29

- Trailing slashes are now removed from
  [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md)
  ([\#134](https://github.com/rstudio/vetiver-r/issues/134)).

- Added support for GAMs from mgcv
  ([\#135](https://github.com/rstudio/vetiver-r/issues/135)) and stacks
  ([\#138](https://github.com/rstudio/vetiver-r/issues/138)).

- Added `augment` method for vetiver endpoint
  ([\#141](https://github.com/rstudio/vetiver-r/issues/141)).

- Added `apt-get clean` to Dockerfile to reduce container size
  ([\#142](https://github.com/rstudio/vetiver-r/issues/142), thanks to
  [@csgillespie](https://github.com/csgillespie)).

- Fixed bug where not all system requirements were added to the
  Dockerfile ([\#142](https://github.com/rstudio/vetiver-r/issues/142),
  thanks to [@csgillespie](https://github.com/csgillespie)).

- Added bundle support for relevant models
  ([\#145](https://github.com/rstudio/vetiver-r/issues/145)).

- Fixed bug in generating Dockerfiles when explicitly requiring the
  stats package
  ([\#147](https://github.com/rstudio/vetiver-r/issues/147)).

## vetiver 0.1.7

CRAN release: 2022-08-11

- Now pass the dots for writing a pin through to vetiver allowing, for
  example, `vetiver_pin_write(b, v, access_type = "all")` on RStudio
  Connect ([\#121](https://github.com/rstudio/vetiver-r/issues/121),
  [\#122](https://github.com/rstudio/vetiver-r/issues/122)).

- [`vetiver_pin_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_metrics.md)
  now finds the `type` of the existing pin and updates with the same
  type ([\#122](https://github.com/rstudio/vetiver-r/issues/122)).

## vetiver 0.1.6

CRAN release: 2022-07-06

- The lockfile created by
  [`vetiver_write_docker()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_write_docker.md)
  can now be named via the argument `lockfile`, and its default is
  `vetiver_renv.lock`
  ([\#100](https://github.com/rstudio/vetiver-r/issues/100)).

- Switched the default for `overwrite` in
  [`vetiver_pin_metrics()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_metrics.md)
  from `TRUE` to `FALSE`. Using `FALSE` is a better choice for
  interactive use while `TRUE` is probably the right choice for reports
  or dashboards that are executed on a schedule
  ([\#104](https://github.com/rstudio/vetiver-r/issues/104)).

- Added an optional `EXPOSE PORT` line to the generated Dockerfile, to
  help out Docker Desktop users
  ([\#105](https://github.com/rstudio/vetiver-r/issues/105)).

- Added model monitoring dashboard template
  ([\#98](https://github.com/rstudio/vetiver-r/issues/98)). To knit the
  example vetiver monitoring dashboard, execute
  [`vetiver::pin_example_kc_housing_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_dashboard.md)
  to set up demo model and metrics pins.

- The OpenAPI spec generated for a vetiver model now includes the model
  *version* when applicable.

- Added option to write a Plumber file without packages listed for
  RStudio Connect purposes
  ([\#112](https://github.com/rstudio/vetiver-r/issues/112)).

- Added new function
  [`vetiver_create_rsconnect_bundle()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_rsconnect_bundle.md)
  as an alternative deployment strategy
  ([\#113](https://github.com/rstudio/vetiver-r/issues/113)).

## vetiver 0.1.5

CRAN release: 2022-05-25

- Add functions for model monitoring
  ([\#92](https://github.com/rstudio/vetiver-r/issues/92)).

- Update all URLs in package for new documentation sites.

## vetiver 0.1.4

CRAN release: 2022-04-28

- Improve how Dockerfiles are generated.

## vetiver 0.1.3

CRAN release: 2022-03-09

- Update all tests to use redaction for snapshots.

- Use ranger conditionally in examples/tests.

## vetiver 0.1.2

CRAN release: 2022-02-16

- Generate Dockerfiles to deploy model
  ([\#71](https://github.com/rstudio/vetiver-r/issues/71)).

- Added support for glm
  ([\#75](https://github.com/rstudio/vetiver-r/issues/75)) and ranger
  ([\#76](https://github.com/rstudio/vetiver-r/issues/76)).

- Deprecated
  [`vetiver_pr_predict()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pr_predict.md)
  in favor of using
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md)
  ([\#77](https://github.com/rstudio/vetiver-r/issues/77)).

## vetiver 0.1.1

CRAN release: 2022-01-07

- Added support for tidymodels
  ([\#51](https://github.com/rstudio/vetiver-r/issues/51)), caret
  ([\#52](https://github.com/rstudio/vetiver-r/issues/52)), and mlr3
  ([\#56](https://github.com/rstudio/vetiver-r/issues/56)).

- Added vignette.

- Escalated parsing/conversion warnings to errors in
  [`vetiver_type_convert()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_type_convert.md)
  ([\#60](https://github.com/rstudio/vetiver-r/issues/60)).

- Added `predict` method for
  [`vetiver_model()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_model.md)
  (in addition to
  [`vetiver_endpoint()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_endpoint.md))
  ([\#61](https://github.com/rstudio/vetiver-r/issues/61)).

- New function
  [`vetiver_deploy_rsconnect()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_deploy_rsconnect.md)
  to deploy to RStudio Connect.

- Added R Markdown template for Model Card for responsible, transparent
  model reporting
  ([\#62](https://github.com/rstudio/vetiver-r/issues/62),
  [\#63](https://github.com/rstudio/vetiver-r/issues/63)).

- Modularized
  [`vetiver_pr_predict()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pr_predict.md)
  to support more advanced use cases
  ([\#67](https://github.com/rstudio/vetiver-r/issues/67)).

## vetiver 0.1.0

CRAN release: 2021-11-02

- Initial CRAN release of package.
