#' Install InVEST and its dependencies
#'
#' @param envname Name of Python environment to install within
#'
#' @param gh_action_runner boolean
#'
#' @param restart_session Restart R session after installing (note this will
#'   only occur within RStudio).
#'
#' @importFrom rstudioapi restartSession
#' @export
#' @examples \dontrun{
#' rinvest::install_invest()
#' }
install_invest <- function(envname = "r-reticulate",
                           gh_action_runner = FALSE,
                           restart_session = TRUE) {

  # seems reticulate::py_install can't accept a mix of pip and conda packages!
  if(gh_action_runner){
    system(paste0("conda ", "env update --prefix /Users/runner/Library/r-miniconda/envs/r-reticulate -f ", system.file("requirements-all.yml", package = "rinvest")))
  }else{
    system(paste0("conda ", "env create -f ", system.file("requirements-all.yml", package = "rinvest")))
  }

  cat("\nInstallation complete.\n\n")

  if (restart_session && rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()

  invisible(NULL)
}

# is_invest_installed()
is_invest_installed <- function(){
  reticulate::use_condaenv(condaenv = "r-reticulate", required = TRUE)
  tryCatch(reticulate::import("natcap.invest"), error = function(x) FALSE) != FALSE
}
