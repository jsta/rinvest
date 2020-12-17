#' Install InVEST and its dependencies
#'
#' @param envname Name of Python environment to install within
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
install_invest <- function(envname = "r-reticulate",
                           # gh_action_runner = FALSE,
                           restart_session = TRUE) {

  # seems reticulate::py_install can't accept a mix of pip and conda packages!
  # if(gh_action_runner){
  #   print(system(Sys.getenv("USERNAME")))
  #   system("sudo chown -R runner /usr/local/miniconda")
  #   system(paste0("conda ", "env create --prefix /Users/runner/Library/r-miniconda/envs -f ",
  #                 system.file("requirements-all.yml", package = "rinvest")))
  #
  # }else{
    system(paste0("conda ", "env create -f ", system.file("requirements-all.yml", package = "rinvest")))
  # }

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
