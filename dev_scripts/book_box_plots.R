# 'Clear all'
rm(list = ls())

library(leaflet)
library(tidyverse)
library(sf)
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(corrplot)
library(reshape)
library(scales)
library(gridExtra)  # for arranging multiple plots


# Override ggplot print method to plot in new window
# print.ggplot <- function(...) {
#   dev.new()
#   ggplot2:::print.ggplot(...)
# }


# Read in book box data, COI data, and zip code spatial data
box_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\Book_box_locs.csv')
COI_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\2020_COI_from_zip.csv')
zc_spatial <- st_read('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\georgia-zip-codes-_1578.geojson')


# Convert 'Charted' into a factor (categorical) if it's not already
box_data$Charted <- as.factor(box_data$Charted)
box_data$Zip <- as.factor(box_data$Zip)

# Get unique zip codes
u_zips= unique(box_data$Zip)

# Get COI data for zip codes in book box sheet
sub_COIs <- COI_data %>%
  filter(COI_data$zip %in% u_zips)  

freq_tbl <- as.data.frame(table(box_data$Zip))
# freq2 <- tabulate(box_data$Zip)



# ggplot(df, aes(x= n_books, y= r_coi_nat)) + 
#   geom_point(size=6, color="#69b3a2") 
# theme_ipsum()


# demographics <- as.matrix(sub_COIs[, 7:12])
# dem_norm <- demographics / sub_COIs$pop
dem_norm <- data.frame(sub_COIs$zip, sub_COIs[, 7:12] / sub_COIs$pop)
names(dem_norm)[names(dem_norm) == 'sub_COIs.zip'] <- 'zip'

dem_norm$zip <- as.factor(dem_norm$zip)

mdem <- melt(dem_norm, id.vars = "zip")


# Make a function for Shannon Entropy
shannon_entropy <- function(row) {
  # Normalize the row to ensure it sums to 1 (i.e., convert to probabilities)
  prob <- row / sum(row)
  
  # Filter out zero probabilities to avoid log(0)
  prob <- prob[prob > 0]
  
  # Compute entropy
  entropy <- -sum(prob * log2(prob))
  
  return(entropy)
}

# Use 'apply' to compute entropy row-wise (1 indicates rows)
SE <- apply(dem_norm[, 2:7], 1, shannon_entropy)

df <- data.frame(freq_tbl$Freq, sub_COIs[, 25:28], SE) 
colnames(df) <- c('n_books', 'r_ed_nat', 'r_he_nat','r_se_nat', 'r_coi_nat', 's_entropy') 
rownames(df) <- dem_norm$zip

dem_norm$SE <- SE


ps <- ggplot(dem_norm, aes(x = zip, y = SE)) +
  geom_point(color = "red", size = 3, shape = 21, fill = "white") +
  geom_line(aes(group = 1), color = "red", linetype = "dashed") +
  theme_minimal() +
  labs(title = "Shannon Entropy Values",
       y = "Entropy") +
  theme(axis.text.x = element_blank())

pb <- ggplot(mdem, aes(zip, value, fill = variable)) +
  geom_bar(position = "fill", stat = "identity") +
  scale_y_continuous(labels = percent) +
  scale_fill_discrete(name = "race") +
  ylab("demographic share") +
  # Place legend below plot & rotate zip labels
  theme(legend.position = "bottom", 
        axis.text.x = element_text(angle = 45, hjust = 1))  

# Arrange the two plots vertically
windows()
grid.arrange(ps, pb, nrow = 2, heights = c(1, 2))


dat2plt <- t(as.matrix(dem_norm[, 2:7]))

lbl <- dat2plt
lbl[ lbl>=0.005 ] <- 1
lbl[ lbl< 0.005 ] <- 0
lbl= +(!lbl)

# Add colnames or corrplot will get upset about p.mat
colnames(lbl) <- dem_norm$zip
colnames(dat2plt) <- dem_norm$zip

windows()
corrplot(dat2plt, is.corr = FALSE, method = 'circle',
         p.mat = lbl, sig.level = 0.005, insig = 'blank',
         col = COL1("Purples"), addCoef.col ='black', col.lim = c(0, 1))
