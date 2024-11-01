library(viridisLite)
library(viridis)
library(leaflet)
library(shiny)
library(sf)
library(readr)
library(dplyr)

# Read in book box data, COI data, and zip code spatial data
box_data <- read.csv("data/Book_box_locs.csv")
COI_data <- read.csv("data/2020_COI_from_zip.csv")
zc_spatial <- st_read("data/georgia-zip-codes-_1578.geojson")

# Make some categorical variables
box_data$Zip <- as.factor(box_data$Zip)
box_data$Charted <- factor(box_data$Charted, levels = c(0, 1), labels = c("unlisted", "listed"))
box_data$Self_collected <- factor(box_data$Self_collected, levels = c(0, 1), labels = c("no", "yes"))

# Get unique zip codes
u_zips = unique(box_data$Zip)

# Get COI data for zip codes in book box sheet
sub_COIs <- COI_data %>%
  filter(COI_data$zip %in% u_zips)

freq_tbl <- as.data.frame(table(box_data$Zip))

# Normalize selected demographic columns by population
dem_norm <- data.frame(sub_COIs$zip, sub_COIs[, 7:12] / sub_COIs$pop)
names(dem_norm)[names(dem_norm) == 'sub_COIs.zip'] <- 'zip'
dem_norm$zip <- as.factor(dem_norm$zip)

# Shannon Entropy function -- for community diversity
shannon_entropy <- function(row) {
  prob <- row / sum(row)
  prob <- prob[prob > 0]
  -sum(prob * log2(prob))
}

# Compute diversity
SE <- apply(dem_norm[, 2:7], 1, shannon_entropy)

dem_norm$SE <- SE


# Create data frame 'df' with box count, zip-level COI comps, & demographic diversity
zip_df <- data.frame(freq_tbl$Freq, sub_COIs[, 25:28], SE)
colnames(zip_df) <- c('n_boxes', 
                      'r_ed_nat', 
                      'r_he_nat', 
                      'r_se_nat', 
                      'r_coi_nat', 
                      's_entropy')

# Sort book box data by zip code and remove NAs
zs_box_data <- box_data[order(box_data$Zip),]

zs_box_data <- zs_box_data %>%
  filter(!is.na(Latitude) & !is.na(Longitude))


# Expand data frame by repeating COI / entropy data for repeat zip codes
location_df <- zip_df[rep(seq_len(nrow(zip_df)), times = freq_tbl$Freq), ]
location_df$self_c <- zs_box_data$Self_collected
location_df$charted <- zs_box_data$Charted
rownames(location_df) <- NULL


# Merge for plotting & clean-up empty street numbers
merged_dat <- cbind(zs_box_data, location_df)
merged_dat$Number[is.na(merged_dat$Number)] <- ""


# Filter and sort spatial data to include only zip codes in bookbox table
sub_zc <- zc_spatial %>%
  filter(zc_spatial$ZCTA5CE10 %in% u_zips)

sub_z_srt = sub_zc %>%
  arrange(ZCTA5CE10)

# Associate column variables with clean drop-down menu choices
zip_choices= c("Number of boxes" = "n_boxes",
               "Ed resources" = "r_ed_nat", 
               "Health, env, safety" = "r_he_nat", 
               "Socioeconomic" = "r_se_nat", 
               "Composite COI" = "r_coi_nat", 
               "Community diversity" = "s_entropy")

box_choices= c(zip_choices, 
               "Self-collected" = "self_c", 
               "Online" = "charted")

n_bins <- 7    # default bin number for color palettes

# Convert zip/box choices to list that can be passed to legend titles
var_lookup <- setNames(as.list(names(box_choices)), unlist(box_choices))


# Load modules
source("modules/paletteButtonUI.R")
source("modules/paletteButtonServer.R")
source("modules/tabMapUI.R")
source("modules/tabAboutUI.R")
source("modules/tabMapServer.R")

