#' Nutrient Delivery Ratio (NDR) Model
#'
#' @param args named list of model arguments
#' @param overwrite boolean
#'
#' @export
#'
#' @examples \dontrun{
#'
#' ndr(ndr_testdata_args, overwrite = TRUE)
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

  preflight_checks_ndr(args)

  args_py <- reticulate::r_to_py(args)
  ndr <- invest$ndr$ndr
  ndr$execute(args_py)

  res <- dir(workspace_path,
      full.names = TRUE, include.dirs = TRUE,
      recursive = TRUE, all.files = TRUE)
  res
}

#' Calculate total P export
#'
#' @param ndr_output output of the ndr function. vector of file paths.
#'
#' @importFrom raster raster cellStats
#' @export
#'
ndr_p_export_total <- function(ndr_output){
  # ndr_output <- ndr_file_paths
  p_export_path <- ndr_output[which(basename(ndr_output) == "p_export.tif")]

  raster::cellStats(raster::raster(p_export_path), "sum")
}


# ndr(ndr_testdata_args, overwrite = TRUE)
preflight_checks_ndr <- function(args, checks =
                                   c("int_rasters", "lulc_code_match",
                                     "raster_extent_match")){

  ## int_rasters
  # sf::gdal_utils("info", args$lulc_path)
  if(length(grep("INT", raster::dataType(raster::raster(args$lulc_path)))) == 0){
    stop("lulc raster not of type integer")
  }

  # lulc_code_match
  lulc_raster <- raster::unique(raster::raster(args$lulc_path))
  lulc_biophys <- read.csv(args$biophysical_table_path, stringsAsFactors = FALSE)$lucode
  if(!all(lulc_raster %in% lulc_biophys)){
    stop(paste0(lulc_raster[!(lulc_raster %in% lulc_biophys)],
                " undefined in biophys table"))
  }

  # raster_extent_match
  raster_extents <- lapply(
    list(args$lulc_path, args$dem_path, args$runoff_proxy_path),
    function(x) raster::extent(raster::raster(x)))
  if(!all(sapply(raster_extents, FUN = identical, raster_extents[[1]]))){
    stop("input rasters have differing spatial extents")
  }

}


