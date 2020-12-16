#' Install InVEST and its dependencies
#'
#' @param restart_session Restart R session after installing (note this will
#'   only occur within RStudio).
#'
#' @importFrom rstudioapi restartSession
#'
#' @export
#' @examples \dontrun{
#' rinvest::install_invest()
#' }
install_invest <- function(# method = c("auto", "virtualenv", "conda"),
                             # conda = "auto",
                             # version = "default",
                             # envname = NULL,
                             # extra_packages = NULL,
                             restart_session = TRUE
                             # conda_python_version = "3.6",
                               ) {

  # verify 64-bit
  # if (.Machine$sizeof.pointer != 8) {
  #   stop("Unable to install InVEST on this platform.",
  #        "Binary installation is only available for 64-bit platforms.")
  # }
  #
  # method <- match.arg(method)

  # unroll version
  # ver     <- parse_invest_version(version)
  # version <- ver$version
  # package <- ver$package
  #
  # extra_packages <- unique(extra_packages)

  # reticulate::py_install(
  #   packages       = c(package, extra_packages),
  #   envname        = envname,
  #   method         = method,
  #   conda          = conda,
  #   python_version = conda_python_version,
  #   pip            = TRUE,
  #   ...
  # )

  # py_install can't accept a mix of pip and conda packages...
  system2("conda", paste0("env update -f ", system.file("requirements-all.yml", package = "rinvest")))

  cat("\nInstallation complete.\n\n")

  if (restart_session && rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()

  invisible(NULL)
}
