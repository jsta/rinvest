
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rinvest

<!-- badges: start -->

[![R-CMD-check](https://github.com/jsta/rinvest/workflows/R-CMD-check/badge.svg)](https://github.com/jsta/rinvest/actions)
<!-- badges: end -->

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jsta/rinvest")
install_invest()
```

## Example

``` r
library(rinvest)
ndr <- invest$ndr$ndr
data_dir <- system.file("extdata/NDR", package = "rinvest")

args <- dict(
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
  "subsurface_critical_length_p" = 25
)

unlink("workspace", recursive = TRUE)
ndr$execute(args)
```

``` r
dir("workspace")
#> [1] "intermediate_outputs"      "p_export.tif"             
#> [3] "watershed_results_ndr.dbf" "watershed_results_ndr.prj"
#> [5] "watershed_results_ndr.shp" "watershed_results_ndr.shx"
```

``` r
library(raster)

plot(raster("workspace/p_export.tif"), main = "P export")
```

![](man/figures/README-unnamed-chunk-3-1.png)
