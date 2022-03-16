tmp_dir <- fs::path_real(withr::local_tempdir())
rel_dir <- fs::path_rel(tmp_dir)

redact_vetiver <- function(snapshot) {
    snapshot <- gsub(rel_dir, "<redacted>", snapshot, fixed = TRUE)
    snapshot <- gsub(tmp_dir, "<redacted>", snapshot, fixed = TRUE)
    snapshot <- gsub(getRversion(), "<r_version>", snapshot, fixed = TRUE)
}
