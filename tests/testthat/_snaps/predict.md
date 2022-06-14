# can predict on basic vetiver router

    Code
      print(endpoint)
    Output
      
      -- A model API endpoint for prediction: 
      http://localhost:<port>/predict

# get correct errors

    Code
      predict(endpoint, mtcars[, 2:4])
    Condition
      Error in `predict()`:
      ! Failed to predict: Error in `hardhat::scream()`:
      ! Can't convert from `data` <tbl_df<
        cyl : integer
        disp: double
        hp  : integer
      >> to <tbl_df<
        cyl : double
        disp: double
      >> due to loss of precision.

---

    Code
      predict(endpoint, mtcars[, 3:5])
    Condition
      Error in `predict()`:
      ! Failed to predict: Error in `glubort()`:
      ! The following required columns are missing: 'cyl'.

