
# Loading Python modules
# See https://rstudio.github.io/reticulate/articles/package.html
#' @importFrom reticulate import
invest <- NULL

.onLoad <- function(libname, pkgname) {
  tryCatch(
  invest <<- reticulate::import("natcap.invest", delay_load = TRUE),
  error = Sys.sleep(0))
}
