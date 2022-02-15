# old function is deprecated

    Code
      pr() %>% vetiver_pr_predict(v)
    Warning <lifecycle_warning_deprecated>
      `vetiver_pr_predict()` was deprecated in vetiver 0.1.2.
      Please use `vetiver_api()` instead.
    Output
      # Plumber router with 2 endpoints, 4 filters, and 0 sub-routers.
      # Use `pr_run()` on this object to start the API.
      ├──[queryString]
      ├──[body]
      ├──[cookieParser]
      ├──[sharedSecret]
      ├──/ping (GET)
      └──/predict (POST)

