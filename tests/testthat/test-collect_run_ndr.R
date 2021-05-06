test_that("collect_run_ndr works", {
  unlink("workspace_temp", recursive = TRUE)
  collect_run_ndr(ndr_testdata_args(), symlink = TRUE)
  # dir("workspace_temp")
  testthat::expect_gt(length(dir("workspace_temp")), 8)
})