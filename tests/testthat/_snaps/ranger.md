# can print ranger model

    Code
      v
    Output
      
      -- cars3 - <ranger> model for deployment 
      A ranger regression model using 10 features

# error for no prototype_data with ranger

    Code
      vetiver_model(cars_rf, "cars3")
    Condition
      Error in `vetiver_ptype()`:
      ! No `prototype_data` available to create an input data prototype
      * Pass at least one row of training features as `prototype_data`
      * See the documentation for `vetiver_ptype()`

# create plumber.R for ranger

    Code
      cat(readr::read_lines(tmp), sep = "\n")
    Output
      # Generated by the vetiver package; edit with care
      
      library(pins)
      library(plumber)
      library(rapidoc)
      library(vetiver)
      
      # Packages needed to generate model predictions
      if (FALSE) {
          library(ranger)
      }
      b <- board_folder(path = "<redacted>")
      v <- vetiver_pin_read(b, "cars3")
      
      #* @plumber
      function(pr) {
          pr %>% vetiver_api(v)
      }

