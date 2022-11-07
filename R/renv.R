
#
# renv 0.16.0-28: A dependency management toolkit for R.
# Generated using `renv:::vendor()` at 2022-11-07 12:02:22.
#


renv <- new.env(parent = new.env())

renv$imports <- list(
  utils = c(
    "URLencode",
    "adist",
    "available.packages",
    "browseURL",
    "citation",
    "contrib.url",
    "download.file",
    "download.packages",
    "file.edit",
    "getCRANmirrors",
    "head",
    "help",
    "install.packages",
    "installed.packages",
    "modifyList",
    "old.packages",
    "packageDescription",
    "packageVersion",
    "read.table",
    "remove.packages",
    "sessionInfo",
    "str",
    "tail",
    "tar",
    "toBibtex",
    "untar",
    "unzip",
    "update.packages",
    "zip"
  )
)

renv$initialize <- function() {

  attr(renv, "name") <- "embedded:renv"
  attr(parent.env(renv), "name") <- "imports:renv"

  for (package in names(renv$imports)) {
    namespace <- asNamespace(package)
    functions <- renv$imports[[package]]
    list2env(mget(functions, envir = namespace), envir = parent.env(renv))
  }

  script <- system.file("vendor/renv.R", package = .packageName)
  sys.source(script, envir = renv)

}
