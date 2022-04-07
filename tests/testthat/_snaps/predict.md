# get correct errors

    Code
      predict(endpoint, mtcars[, 2:4])
    Error <rlang_error>
      Failed to predict: Error in `hardhat::scream()` at vetiver-r/R/lm.R:31:12:
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
    Error <rlang_error>
      Failed to predict: Error in `glubort()`:
      ! The following required columns are missing: 'cyl'.

