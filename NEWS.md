# vetiver 0.2.5

* Fixed bug in generating plumber files (#257).

# vetiver 0.2.4

* Fixed how plumber files are generated for `board_url()` (#241).

# vetiver 0.2.3

* Updated test involving renv and rsconnect (#230).

# vetiver 0.2.2

* Fixed a bug in where `vetiver_write_docker()` writes the renv lockfile (#212).

* Added new `/prototype` GET endpoint for a model's input data prototype (#220).

# vetiver 0.2.1

* Added support for keras (#164), recipes (#179), and luz (#187, @dfalbel).

* Moved where `required_pkgs` metadata is stored remotely, from the binary blob to plain text YAML (#176).

* Added an optional renv lockfile that can be stored remotely in model metadata, with a new `check_renv` argument for reading/writing (#154, #192).

* Exposed a new `base_image` argument for creating Dockerfiles (#182).

* Added new `vetiver_deploy_sagemaker()` function plus `vetiver_endpoint_sagemaker()` and other needed functionality for deploying on Amazon SageMaker (#186, @DyfanJones).

* Added new additional GET endpoint for model `/metadata` (#194).

# vetiver 0.2.0

## Breaking changes

* The arguments for dealing with a model's input data prototype have changed from using `ptype` to using `prototype` (#166): 
    * In `vetiver_model()`, now use `save_prototype`.
    * In `vetiver_api()`, now use `check_prototype`.

## Other improvements

* Added support for k-Prototypes clustering from clustMixType (#163, thanks to @galen-ft).

* Now vendor renv directly in package (#157).

* Fixed how `vetiver_ptype()` finds predictors for models (`lm()` and `glm()`) with interactions (#160).

* New argument added to `vetiver_write_docker()` to pass in additional packages to be installed, such as `required_pkgs(board)` (#159).

* New function `vetiver_prepare_docker()` creates all necessary files to deploy a basic vetiver model via Docker (#165).

* Fixed a bug in handling all-`NA` columns when predicting on a `vetiver_endpoint()` (#169).

# vetiver 0.1.8

* Trailing slashes are now removed from `vetiver_endpoint()` (#134).

* Added support for GAMs from mgcv (#135) and stacks (#138).

* Added `augment` method for vetiver endpoint (#141).

* Added `apt-get clean` to Dockerfile to reduce container size (#142, thanks to @csgillespie).

* Fixed bug where not all system requirements were added to the Dockerfile (#142, thanks to @csgillespie).

* Added bundle support for relevant models (#145).

* Fixed bug in generating Dockerfiles when explicitly requiring the stats package (#147).

# vetiver 0.1.7

* Now pass the dots for writing a pin through to vetiver allowing, for example, `vetiver_pin_write(b, v, access_type = "all")` on RStudio Connect (#121, #122).

* `vetiver_pin_metrics()` now finds the `type` of the existing pin and updates with the same type (#122).

# vetiver 0.1.6

* The lockfile created by `vetiver_write_docker()` can now be named via the argument `lockfile`, and its default is `vetiver_renv.lock` (#100).

* Switched the default for `overwrite` in `vetiver_pin_metrics()` from `TRUE` to `FALSE`. Using `FALSE` is a better choice for interactive use while `TRUE` is probably the right choice for reports or dashboards that are executed on a schedule (#104).

* Added an optional `EXPOSE PORT` line to the generated Dockerfile, to help out Docker Desktop users (#105).

* Added model monitoring dashboard template (#98). To knit the example vetiver monitoring dashboard, execute `vetiver::pin_example_kc_housing_model()` to set up demo model and metrics pins.

* The OpenAPI spec generated for a vetiver model now includes the model _version_ when applicable.

* Added option to write a Plumber file without packages listed for RStudio Connect purposes (#112).

* Added new function `vetiver_create_rsconnect_bundle()` as an alternative deployment strategy (#113).

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

* Added R Markdown template for Model Card for responsible, transparent model reporting (#62, #63).

* Modularized `vetiver_pr_predict()` to support more advanced use cases (#67).

# vetiver 0.1.0

* Initial CRAN release of package.
