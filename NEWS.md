# vetiver (development version)

* The lockfile created by `vetiver_write_docker()` can now be named via the argument `lockfile`, and its default is `vetiver_renv.lock` (#100).

* Switched the default for `overwrite` in `vetiver_pin_metrics()` from `TRUE` to `FALSE`. Using `FALSE` is a better choice for interactive use while `TRUE` is probably the right choice for reports or dashboards that are executed on a schedule (#104).

* Added an optional `EXPOSE PORT` line to the generated Dockerfile, to help out Docker Desktop users (#105).

* Added model monitoring dashboard template (#98). To knit the example vetiver monitoring dashboard, execute `vetiver::pin_example_kc_housing_model()` to set up demo model and metrics pins.

* The OpenAPI spec generated for a vetiver model now includes the model _version_ when applicable.

* Added option to write a Plumber file without packages listed for RStudio Connect purposes (#112).

# vetiver 0.1.5

* Add functions for model monitoring (#92).

* Update all URLs in package for new documentation sites.

# vetiver 0.1.4

* Improve how Dockerfiles are generated.

# vetiver 0.1.3

* Update all tests to use redaction for snapshots.

* Use ranger conditionally in examples/tests.

# vetiver 0.1.2

* Generate Dockerfiles to deploy model (#71).

* Added support for glm (#75) and ranger (#76).

* Deprecated `vetiver_pr_predict()` in favor of using `vetiver_api()` (#77).

# vetiver 0.1.1

* Added support for tidymodels (#51), caret (#52), and mlr3 (#56).

* Added vignette.

* Escalated parsing/conversion warnings to errors in `vetiver_type_convert()` (#60).

* Added `predict` method for `vetiver_model()` (in addition to `vetiver_endpoint()`) (#61).

* New function `vetiver_deploy_rsconnect()` to deploy to RStudio Connect.

* Added R Markdown template for [Model Card](https://doi.org/10.1145/3287560.3287596) for responsible, transparent model reporting (#62, #63).

* Modularized `vetiver_pr_predict()` to support more advanced use cases (#67).

# vetiver 0.1.0

* Initial CRAN release of package.
