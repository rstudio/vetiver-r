# Create a vetiver object for deployment of a trained model

A `vetiver_model()` object collects the information needed to store,
version, and deploy a trained model. Once your `vetiver_model()` object
has been created, you can:

- store and version it as a pin with
  [`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_write.md)

- create an API endpoint for it with
  [`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md)

## Usage

``` r
vetiver_model(
  model,
  model_name,
  ...,
  description = NULL,
  metadata = list(),
  save_prototype = TRUE,
  save_ptype = deprecated(),
  versioned = NULL
)

new_vetiver_model(
  model,
  model_name,
  description,
  metadata,
  prototype,
  versioned
)
```

## Arguments

- model:

  A trained model, such as an [`lm()`](https://rdrr.io/r/stats/lm.html)
  model or a tidymodels
  [`workflows::workflow()`](https://workflows.tidymodels.org/reference/workflow.html).

- model_name:

  Model name or ID.

- ...:

  Other method-specific arguments passed to
  [`vetiver_ptype()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_create_ptype.md)
  to compute an input data prototype, such as `prototype_data` (a sample
  of training features).

- description:

  A detailed description of the model. If omitted, a brief description
  of the model will be generated.

- metadata:

  A list containing additional metadata to store with the pin. When
  retrieving the pin, this will be stored in the `user` key, to avoid
  potential clashes with the metadata that pins itself uses.

- save_prototype:

  Should an input data prototype be stored with the model? The options
  are `TRUE` (the default, which stores a zero-row slice of the training
  data), `FALSE` (no input data prototype for visual documentation or
  checking), or a dataframe to be used for both checking at prediction
  time *and* examples in API visual documentation.

- save_ptype:

  **\[deprecated\]**

- versioned:

  Should the model object be versioned when stored with
  [`vetiver_pin_write()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_pin_write.md)?
  The default, `NULL`, will use the default for the `board` where you
  store the model.

- prototype:

  An input data prototype. If `NULL`, there is no checking of new data
  at prediction time.

## Value

A new `vetiver_model` object.

## Details

You can provide your own data to `save_prototype` to use as examples in
the visual documentation created by
[`vetiver_api()`](https://rstudio.github.io/vetiver-r/dev/reference/vetiver_api.md).
If you do this, consider checking that your input data prototype has the
same structure as your training data (perhaps with
[`hardhat::scream()`](https://hardhat.tidymodels.org/reference/scream.html))
and/or simulating data to avoid leaking PII via your deployed model.

Some models, like
[`ranger::ranger()`](http://imbs-hl.github.io/ranger/reference/ranger.md),
[keras](https://tensorflow.rstudio.com/), and [luz
(torch)](https://torch.mlverse.org/), *require* that you pass in example
training data as `prototype_data` or else explicitly set
`save_prototype = FALSE`. For non-rectangular data input to models, such
as image input for a keras or torch model, we currently recommend that
you turn off prototype checking via `save_prototype = FALSE`.

## Examples

``` r
cars_lm <- lm(mpg ~ ., data = mtcars)
vetiver_model(cars_lm, "cars-linear")
#> 
#> ── cars-linear ─ <butchered_lm> model for deployment 
#> An OLS linear regression model using 10 features
```
