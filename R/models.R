#' Nutrient Delivery Ratio (NDR) Model
#'
#' @param args named list of model arguments
#' @param overwrite boolean
#'
#' @export
#'
#' @examples \dontrun{
#' data_dir <- system.file("extdata/NDR", package = "rinvest")
#' args <- list(
#'   "workspace_dir" = "workspace",
#'   "dem_path" = paste0(data_dir, "/DEM_gura.tif"),
#'   "lulc_path" = paste0(data_dir, "/land_use_gura.tif"),
#'   "runoff_proxy_path" = paste0(data_dir, "/precipitation_gura.tif"),
#'   "watersheds_path" = paste0(data_dir,  "/watershed_gura.shp"),
#'   "biophysical_table_path" = paste0(data_dir,  "/biophysical_table_gura.csv"),
#'   "calc_p" = TRUE,
#'   "calc_n" = FALSE,
#'   "threshold_flow_accumulation" = 1000,
#'   "k_param" = 2,
#'   "subsurface_eff_p" = 0.5,
#'   "subsurface_critical_length_p" = 25
#' )
#'
#' ndr(args)
#'
#' }
ndr <- function(args, overwrite = FALSE){
  reticulate::use_condaenv("r-invest")

  workspace_path <- as.character(args[names(args) == "workspace_dir"])
  if(dir.exists(workspace_path) & overwrite){
    unlink(workspace_path)
  }
  if(dir.exists(workspace_path) & !overwrite){
    stop("Output folder already exists. Consider setting overwrite option.")
  }

  args_py <- reticulate::r_to_py(args)
  ndr <- invest$ndr$ndr
  ndr$execute(args_py)

  res <- dir(workspace_path,
      full.names = TRUE, include.dirs = TRUE,
      recursive = TRUE, all.files = TRUE)
  res
}
