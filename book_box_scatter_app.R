# 'Clear all'
# rm(list = ls())

library(leaflet)
library(tidyverse)
library(sf)
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)

box_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\Book_box_locs.csv')
COI_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\2020_COI_from_zip.csv')

# Convert 'Charted' into a factor (categorical) if it's not already
box_data$Charted <- as.factor(box_data$Charted)
box_data$Zip <- as.factor(box_data$Zip)

# Get unique zip codes
u_zips= unique(box_data$Zip)

# Get COI data for zip codes in book box sheet
sub_COIs <- COI_data %>%
  filter(COI_data$zip %in% u_zips)  

freq_tbl <- as.data.frame(table(box_data$Zip))

df <- data.frame(freq_tbl$Freq, sub_COIs$r_coi_nat) 
colnames(df) <- c('n_books','r_coi_nat') 

# ggplot(df, aes(x= n_books, y= r_coi_nat)) + 
#   geom_point(size=6, color="#69b3a2") 
  # theme_ipsum()

# freq2 <- tabulate(box_data$Zip)

# Read in zip code spatial data
# zc_spatial <- st_read('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\GA_zips')
zc_spatial <- st_read('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\georgia-zip-codes-_1578.geojson')


# Filter spatial data to include only zip codes in smaller table, then sort
sub_zc <- zc_spatial %>%
  filter(zc_spatial$ZCTA5CE10 %in% u_zips)

sub_z_srt= sub_zc %>%
  arrange(ZCTA5CE10) 

# Define a color palette for the markers
pal <- colorFactor(c("blue", "orange"), levels = c("0", "1"))

# Define the UI for the Shiny app
ui <- fluidPage(
  titlePanel("Book Box Locations Map"),
  leafletOutput("map")
)

# Define the server logic for the Shiny app
server <- function(input, output, session) {
  
  
  
  output$map <- renderLeaflet({
    leaflet(box_data) %>%
      addTiles() %>%
      addCircleMarkers(lng = box_data$Longitude, lat = box_data$Latitude,
                       color = ~pal(Charted),
                       popup = paste("Street:", box_data$Street, "<br>",
                                     "Zip:", box_data$Zip, "<br>",
                                     "Latitude:", box_data$Latitude, "<br>",
                                     "Longitude:", box_data$Longitude, "<br>",
                                     "Charted:", box_data$Charted),
                       radius = 6, fillOpacity = 0.7)
  })
}

# addMarkers(lng = box_data$Longitude, lat = box_data$Latitude, 
#            popup = paste("Street:", box_data$Street, "<br>",
#                          "Zip:", box_data$Zip, "<br>",
#                          "Latitude:", box_data$Latitude, "<br>",
#                          "Longitude:", box_data$Longitude))

# Run the Shiny app
shinyApp(ui = ui, server = server)
