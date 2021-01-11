
#' Create native python script and move input files to a clean directory
#'
#' @param args named list of ndr arguments
#' @param out_dir path to temporary working directory
#' @param symlink symlink input files? FALSE copies files instead
#' @param conda_path optional. path to conda executable
#' @param conda_env optional. path to conda environment
#'
#' @importFrom snakecase to_sentence_case
#' @importFrom stringr str_extract
#' @importFrom utils write.csv
#' @importFrom here here
#'
#' @export
#' @examples \dontrun{
#' unlink("workspace_temp", recursive = TRUE)
#' collect_run_ndr(ndr_testdata_args)
#' collect_run_ndr(ndr_testdata_args, symlink = TRUE)
#' )
#' }
collect_run_ndr <- function(args, out_dir = "workspace_temp", symlink = FALSE,
                            conda_path = NULL, conda_env = NULL){
  # args <- ndr_testdata_args
  # copy files
  unlink(out_dir, recursive = TRUE)
  dir.create(out_dir, showWarnings = FALSE)

  ndr_files <- args[grep("_path", names(args))]
  lapply(seq_len(length(ndr_files)), function(i){
    # i <- 1
    file_ext <- stringr::str_extract(ndr_files[i], "\\.[0-9a-z]+$")
    out_path <- paste0(out_dir, "/", names(ndr_files[i]), file_ext)

    if(names(ndr_files[i]) == "watersheds_path"){
      sapply(c(".shx", ".prj", ".dbf"), function(x){
        shp_path_original <- gsub(".shp", x, ndr_files[i])
        shp_path <- paste0(out_dir, "/", names(ndr_files[i]), x)
        if(symlink){
          file.symlink(here::here(shp_path_original), here::here(shp_path))
        }else{
          file.copy(shp_path_original, shp_path)
        }
      })
    }

    if(symlink){
      file.symlink(
        here::here(as.character(ndr_files[i])), here::here(out_path))
    }else{
      file.copy(
        as.character(ndr_files[i]), out_path)
    }
    out_path
  })

  # create an args csv file
  args$calc_n <- snakecase::to_sentence_case(as.character(args$calc_n))
  args$calc_p <- snakecase::to_sentence_case(as.character(args$calc_p))
  args$workspace_dir <- "."
  args[grep("path", names(args))] <- # point appropriate paths base dir
    sapply(
      names(args[grep("path", names(args))]),
      function(y){
        if(y == "watersheds_path"){ return(paste0(y, ".shp")) }else{
          if(y == "biophysical_table_path"){return(paste0(y, "_temp.csv"))}else{
            return(paste0(y, ".tif"))}}
      })

  write.csv(data.frame(args), paste0(out_dir, "/args.csv"),
            quote = FALSE, row.names = FALSE)

  # create python script
  py_path <- paste0(out_dir, "/", "ndr.py")
  unlink(py_path)
  writeLines(c(
    'from natcap.invest.ndr import ndr',
    'import pandas as pd',
    'args = pd.read_csv("args.csv").reset_index(drop = True).to_dict("records")[0]',
    'ndr.execute(args)'),
             py_path)

  # create environment file to enable python execution
  if(!is.null(conda_path) & !is.null(conda_env)){
    envrc_path <- paste0(out_dir, "/", ".envrc")
    unlink(envrc_path)
    writeLines(c(
      paste0('export PATH=', conda_path, ':$PATH'),
      paste0('source activate ', conda_env)),
      envrc_path)
  }

}
