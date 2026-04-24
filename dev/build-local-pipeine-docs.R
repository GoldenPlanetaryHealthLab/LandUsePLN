fusen::inflate(
  flat_file = "dev/flat_build_local_pipeline.Rmd",
  vignette_name = "Pipeline Definition",
  check = FALSE,
  open = FALSE,
  clean = TRUE
)

fs::dir_create("inst/extdata")
fs::file_copy(
  "vignettes/pipeline-definition.Rmd",
  "inst/extdata/pipeline-definition.Rmd",
  overwrite = TRUE
)

devtools::document()
