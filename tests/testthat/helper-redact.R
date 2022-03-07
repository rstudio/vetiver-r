tmp_dir <- normalizePath(withr::local_tempdir(), winslash = "/")

redact_vetiver <- function(snapshot) {
    snapshot <- gsub(tmp_dir, "<redacted>", snapshot)
    snapshot <- gsub(getRversion(), "<r_version>", snapshot)
}
