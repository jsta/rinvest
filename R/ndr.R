#' Nutrient Delivery Ratio (NDR) Model
#'
#' @param args named list of model arguments
#' @param overwrite boolean
#' @param quiet silence most output
#'
#' @importFrom reticulate py_capture_output
#' @export
#'
#' @examples \dontrun{
#'
#' ndr(ndr_testdata_args(), overwrite = TRUE)
#'
#' }
ndr <- function(args, overwrite = FALSE, quiet = TRUE){
  reticulate::use_condaenv("r-invest")

  workspace_path <- as.character(args[names(args) == "workspace_dir"])
  if(dir.exists(workspace_path) & overwrite){
    unlink(workspace_path)
  }
  if(dir.exists(workspace_path) & !overwrite){
    stop("Output folder already exists. Consider setting overwrite option.")
  }

  preflight_checks_ndr(args)

  args_py      <- reticulate::r_to_py(args)
  ndr          <- invest$ndr$ndr
  ndr_messages <- ifelse(quiet,
                         py_capture_output(ndr$execute(args_py)),
                         ndr$execute(args_py)
                         )

  res <- dir(workspace_path,
      full.names = TRUE, include.dirs = TRUE,
      recursive = TRUE, all.files = TRUE)

  ifelse(quiet, return(invisible(res)), return(res))
}

#' Calculate total P export
#'
#' @param output_folder path to ndr output folder
#'
#' @importFrom raster raster cellStats
#' @importFrom utils read.csv
#' @export
#'
#' @examples \dontrun{
#' ndr_p_export_total("workspace")
#' }
ndr_p_export_total <- function(output_folder){
  # output_folder <- "workspace"
  flist <- list.files(output_folder, include.dirs = TRUE, full.names = TRUE)
  res_path <- flist[grep("watershed_results_ndr.shp", flist)]

  as.numeric(sf::st_read(res_path, quiet = TRUE)$p_exp_tot)
  # p_export_path <- flist[which(basename(flist) == "p_export.tif")]
  # raster::cellStats(raster::raster(p_export_path), "sum")
}


# preflight_checks_ndr(ndr_testdata_args())
preflight_checks_ndr <- function(args, checks =
                                   c("file_args_exist", "int_rasters",
                                     "lulc_code_match", "raster_extent_match")){

  # file_args_exist
  ndr_file_args_exist(args)

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
    message(raster_extents)
    stop("input rasters have differing spatial extents")
  }

}

#' check if file args exist
ndr_file_args_exist <- function(args) {
  # args <- args_default

  file_args_index <- grep("path", names(args))
  args_exist <- unlist(lapply(
    file_args_index, function(i) {
      file.exists(as.character(args[i]))
    }))

  if (any(!args_exist)) {
    missing_args <- file_args_index[!args_exist]
    missing_args <- names(args)[missing_args]
    stop(paste0(
      "The following ndr file arguments do not exist: ",
      paste0(missing_args, collapse = ", ")
    ))
  }
  invisible(NULL)
}

#' Summarize NDR inputs
#'
#' @param folder_path path to a folder containing ndr input files
#' @param args optional. named list of ndr args
#'
#' @importFrom dplyr `%>%`
#' @importFrom rlang .data
#' @importFrom stats setNames
#' @export
#'
#' @returns a data.frame where each row is a lulc type and there are columns
#' for:
#' the number of cells of each type, the percent of each type, and the product
#' of the number of each type and load_p from the biophys table
#'
#' @details Assumes that the lulc raster has "lulc" in the file name.
#' @examples \dontrun{
#' summarize_inputs_ndr(folder_path = "inst/extdata/NDR", args = ndr_testdata_args())
#' }
summarize_inputs_ndr <- function(folder_path, args = NULL){
  # folder_path <- "~/Documents/Science/JournalSubmissions/pgml_ploading/scripts/calibration/shared/"

  flist       <- list.files(folder_path, "*.tif",
                      include.dirs = TRUE, full.names = TRUE)
  lulc_path   <- flist[c(grep("lulc", flist), grep("land_use", flist))]
  lulc_path   <- lulc_path[which.min(nchar(lulc_path))]
  lulc_raster <- raster::raster(lulc_path)

  biophys_path  <- list.files(folder_path, "biophys",
                             include.dirs = TRUE, full.names = TRUE)
  biophys_table <- read.csv(biophys_path, stringsAsFactors = FALSE)

  # tabulate the number/percent of lulc cells of each type
  # return the product of cell number and load_p
  res <-
    as.data.frame(table(raster::values(lulc_raster)), stringsAsFactors = FALSE) %>%
    setNames(c("lucode", "total_cells")) %>%
    dplyr::mutate(lucode = as.integer(.data$lucode)) %>%
    dplyr::mutate(percent_cells = round(prop.table(.data$total_cells) * 100, 2)) %>%
    dplyr::left_join(biophys_table, by = "lucode") %>%
    dplyr::mutate(total_load_p = .data$load_p * .data$total_cells) %>%
    dplyr::mutate(percent_load_p = round(prop.table(.data$total_load_p) * 100, 2)) %>%
    dplyr::select(.data$description, .data$lucode:.data$percent_cells,
                  .data$total_load_p, .data$percent_load_p, .data$load_p)

  res
}

#' Summarize NDR outputs
#'
#' @param folder_path path to a folder containing ndr output files
#'
#' @export
#'
#' @examples \dontrun{
#' output_summary <- summarize_outputs_ndr(folder_path = "workspace")
#' }
summarize_outputs_ndr <- function(folder_path){
  # folder_path <- "workspace"

  # the average areal P load in the catchment
  flist <- list.files(folder_path, include.dirs = TRUE, full.names = TRUE)
  res_path <- flist[grep(".shp", flist)]
  res_shp <- sf::st_read(res_path, quiet = TRUE)
  avg_areal_p_load <- as.numeric(res_shp$surf_p_ld / sf::st_area(res_shp)) # kg / m2
  avg_areal_p_load <- avg_areal_p_load * 1000 # g / m2

  # total P export
  total_p_export <- ndr_p_export_total("workspace")

  # average areal P export of the catchment
  avg_areal_p_export <- total_p_export / sf::st_area(res_shp) # kg / m2
  avg_areal_p_export <- avg_areal_p_export * 1000 # g / m2

  # a list of output rasters
  flist       <- list.files(paste0(folder_path, "/intermediate_outputs"),
                            pattern = "*.tif",
                            include.dirs = TRUE, full.names = TRUE)
  rstack <- raster::stack(flist)

  list(avg_areal_p_load = avg_areal_p_load, total_p_export = total_p_export,
              avg_areal_p_export = avg_areal_p_export, rstack = rstack)
}

#' Test NDR arguments using included data
#'
#' @export
#'
#' @examples \dontrun{
#' ndr_testdata_args()
#' }
ndr_testdata_args <- function(){
  data_dir <- system.file("extdata/NDR", package = "rinvest")
  ndr_testdata_args <- list(
    "workspace_dir" = "workspace",
    "dem_path" = paste0(data_dir, "/DEM_gura.tif"),
    "lulc_path" = paste0(data_dir, "/land_use_gura.tif"),
    "runoff_proxy_path" = paste0(data_dir, "/precipitation_gura.tif"),
    "watersheds_path" = paste0(data_dir,  "/watershed_gura.shp"),
    "biophysical_table_path" = paste0(data_dir,  "/biophysical_table_gura.csv"),
    "calc_p" = TRUE,
    "calc_n" = FALSE,
    "threshold_flow_accumulation" = 1000,
    "k_param" = 2,
    "subsurface_eff_p" = 0.5,
    "subsurface_critical_length_p" = 25,
    "subsurface_eff_n" = 0,
    "subsurface_critical_length_n" = 0
  )

  ndr_testdata_args
}
