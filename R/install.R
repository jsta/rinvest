#' Install InVEST and its dependencies
#'
#' @inheritParams reticulate::conda_list
#'
#' @param method Installation method. By default, "auto" automatically finds a
#'   method that will work in the local environment. Change the default to force
#'   a specific installation method. Note that the "virtualenv" method is not
#'   available on Windows. Note also that since this command runs without
#'   privilege the "system" method is available only on Windows.
#'
#' @param version InVEST version to install.
#'
#'   You can also provide a full major.minor.patch specification (e.g. "1.1.0").
#'
#'   Alternatively, you can provide the full URL to an installer binary (e.g.
#'   for a nightly binary).
#'
#' @param envname Name of Python environment to install within
#'
#' @param extra_packages Additional Python packages to install along with
#'   InVEST.
#'
#' @param restart_session Restart R session after installing (note this will
#'   only occur within RStudio).
#'
#' @param conda_python_version the python version installed in the created conda
#'   environment. Python 3.6 is installed by default.
#'
#' @param ... other arguments passed to [reticulate::conda_install()] or
#'   [reticulate::virtualenv_install()].
#'
#' @importFrom rstudioapi restartSession
#'
#' @export
#' @examples \dontrun{
#' install_invest()
#' }
install_invest <- function(method = c("auto", "virtualenv", "conda"),
                               conda = "auto",
                               version = "default",
                               envname = NULL,
                               extra_packages = NULL,
                               restart_session = TRUE,
                               conda_python_version = "3.6",
                               ...) {

  # verify 64-bit
  if (.Machine$sizeof.pointer != 8) {
    stop("Unable to install InVEST on this platform.",
         "Binary installation is only available for 64-bit platforms.")
  }

  method <- match.arg(method)

  # unroll version
  ver     <- parse_invest_version(version)
  version <- ver$version
  package <- ver$package

  extra_packages <- unique(extra_packages)

  reticulate::py_install(
    packages       = c(package, extra_packages),
    envname        = envname,
    method         = method,
    conda          = conda,
    python_version = conda_python_version,
    pip            = TRUE,
    ...
  )

  cat("\nInstallation complete.\n\n")

  if (restart_session && rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()

  invisible(NULL)
}

#' @noRd
parse_invest_version <- function(version) {

  default_version <- "3.9.0"

  ver <- list(
    version = default_version,
    package = NULL
  )

  if (version == "default") {

    ver$package <- paste0("natcap.invest==", ver$version)


  } else {

    ver$version <- version

  }

  ver
}
