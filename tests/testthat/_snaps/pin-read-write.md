# can pin a model

    Code
      v
    Output
      
      -- cars1 - <butchered_lm> model for deployment 
      An OLS linear regression model using 2 features

# right message for reading with `check_renv`

    Code
      vetiver_pin_read(b, "cars5", check_renv = TRUE)
    Message
      There is no lockfile stored with "cars5":
      i Use `check_renv = TRUE` when you save your model to your board
    Output
      
      -- cars5 - <butchered_lm> model for deployment 
      An OLS linear regression model using 2 features

