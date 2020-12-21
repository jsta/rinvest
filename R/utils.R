
#' Create native python script and move input files to a clean directory
#'
#' @param args named list of ndr arguments
#' @param conda_path path to conda executable
#' @param conda_env path to conda environment
#' @param out_dir path to temporary working directory
#'
#' @importFrom snakecase to_sentence_case
#' @importFrom stringr str_extract
#' @export
#' @examples \dontrun{
#' collect_run_ndr(ndr_testdata_args,
#' conda_path = paste0("/home/", Sys.info()[["user"]], "/anaconda3/bin"),
#' conda_env = paste0("/home/", Sys.info()[["user"]], "/Documents/Science/Models/invest/env")
#' )
#' }
collect_run_ndr <- function(args, conda_path, conda_env, out_dir = "workspace_temp"){
  # args <- ndr_testdata_args
  unlink(out_dir)
  dir.create(out_dir)

  ndr_files <- args[grep("_path", names(args))]
  lapply(seq_len(length(ndr_files)), function(i){
    # i <- 1
    file_ext <- stringr::str_extract(ndr_files[i], "\\.[0-9a-z]+$")
    out_path <- paste0(out_dir, "/", names(ndr_files[i]), file_ext)

    if(names(ndr_files[i]) == "watersheds_path"){
      # browser()
      shx_path_original <- gsub(".shp", ".shx", ndr_files[i])
      shx_path <- paste0(out_dir, "/", names(ndr_files[i]), ".shx")
      file.copy(shx_path_original, shx_path)
    }

    file.copy(
      as.character(ndr_files[i]), out_path)
    out_path
  })

  envrc_path <- paste0(out_dir, "/", ".envrc")
  unlink(envrc_path)
  writeLines(c(
    paste0('export PATH=', conda_path, ':$PATH'),
    paste0('source activate ', conda_env)),
             envrc_path)

  py_path <- paste0(out_dir, "/", "ndr.py")
  unlink(py_path)
  writeLines(c('from natcap.invest.ndr import ndr',
               'args = {',
               '\t "workspace_dir": ".",',
               paste0('\t "dem_path": "', 'dem_path.tif",'),
               paste0('\t "lulc_path": "', 'lulc_path.tif",'),
               paste0('\t "runoff_proxy_path": "', 'runoff_proxy_path.tif",'),
               paste0('\t "watersheds_path": "', 'watersheds_path.shp",'),
               paste0('\t "biophysical_table_path": "', 'biophysical_table_path.csv",'),
               paste0('\t "calc_p": ', snakecase::to_sentence_case(
                 as.character(args[which(names(args) == "calc_p")])), ','),
               paste0('\t "calc_n": ', snakecase::to_sentence_case(
                 as.character(args[which(names(args) == "calc_n")])), ','),
               paste0('\t "threshold_flow_accumulation": ', args[which(names(args) == "threshold_flow_accumulation")], ','),
               paste0('\t "k_param": ', args[which(names(args) == "k_param")], ','),
               paste0('\t "subsurface_eff_p": ', args[which(names(args) == "subsurface_eff_p")], ','),
               paste0('\t "subsurface_critical_length_p": ', args[which(names(args) == "subsurface_critical_length_p")]),
               "}",
               "ndr.execute(args)"),
             py_path)

}
