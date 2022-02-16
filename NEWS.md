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
