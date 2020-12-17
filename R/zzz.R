# reference: https://rstudio.github.io/reticulate/articles/package.html

#' InVEST object
#'
#' Uses the reticulate framework to access the InVEST API.
#'
#' The InVEST Python library is exposed through the `invest` object.
#'
#' In this package, use the `$` operator wherever you see the `.` operator
#' used in Python.
#'
#' @export invest
invest <- NULL

#' @importFrom reticulate import
.onLoad <- function(libname, pkgname) {
  # tryCatch(
  #   reticulate::use_condaenv(condaenv = "r-reticulate", required = TRUE),
  #   error = Sys.sleep(0))

  tryCatch(
  invest <<- reticulate::import("natcap.invest", delay_load = TRUE),
  error = Sys.sleep(0))
}
