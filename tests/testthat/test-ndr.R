test_that("ndr works", {
  unlink("workspace", recursive = TRUE)
  ndr(ndr_testdata_args(), overwrite = TRUE)
  testthat::expect_true(file.exists("workspace/p_export.tif"))
  unlink("workspace", recursive = TRUE)
})
