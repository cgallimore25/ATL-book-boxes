library(viridisLite)
library(viridis)
library(leaflet)
library(shiny)
library(shinybrowser)
library(sf)
# library(readr)
# library(dplyr)

# Read in book box data, COI data, and zip code spatial data
merged_dat <- readRDS("data/box_locs_COI_matched.rds")
sub_z_srt <- st_read("data/zip_polygons.shp")
zip_df <- readRDS("data/zip_COI_data.rds")


# Associate column variables with clean drop-down menu choices
zip_choices= c("Box count" = "n_boxes",
               "Ed resources" = "r_ed_nat", 
               "Health & safety" = "r_he_nat", 
               "Socioeconomic" = "r_se_nat", 
               "Composite COI" = "r_coi_nat", 
               "Diversity index" = "s_entropy")

box_choices= c(zip_choices, 
               "Self-collected" = "self_c", 
               "Online" = "charted")

n_bins  <- 7    # default bin number for color palettes
n_boxes <- nrow(merged_dat)

# Convert zip/box choices to list that can be passed to legend titles
var_lookup <- setNames(as.list(names(box_choices)), unlist(box_choices))


# Load all modules
source("modules/controlPanelUI.R")
source("modules/controlPanelServer.R")
source("modules/mobileDetect.R")
source("modules/paletteButtonUI.R")
source("modules/paletteButtonServer.R")
source("modules/tabMapUI.R")
source("modules/tabAboutUI.R")
source("modules/tabMapServer.R")
