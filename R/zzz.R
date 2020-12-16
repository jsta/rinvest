
# Loading Python modules
# See https://rstudio.github.io/reticulate/articles/package.html
#' @importFrom reticulate import
invest <- NULL

.onLoad <- function(libname, pkgname) {
  invest <<- reticulate::import("natcap.invest", delay_load = TRUE)
}
