
# Loading Python modules
# See https://rstudio.github.io/reticulate/articles/package.html
invest <- NULL

.onLoad <- function(libname, pkgname) {
  invest <<- reticulate::import("invest", delay_load = TRUE)
}
