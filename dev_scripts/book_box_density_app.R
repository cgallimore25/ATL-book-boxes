# Clear all
rm(list = ls())

library(leaflet)
library(tidyverse)
library(sf)
library(shiny)
library(readr)
library(dplyr)

# Read in book box data, COI data, and zip code spatial data
box_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\Book_box_locs.csv')
COI_data <- read.csv('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\2020_COI_from_zip.csv')
zc_spatial <- st_read('C:\\Users\\cgallimore1\\Documents\\ATL-book-box\\shiny\\georgia-zip-codes-_1578.geojson')

# Convert 'Charted' into a factor (categorical) if it's not already
box_data$Charted <- as.factor(box_data$Charted)
box_data$Zip <- as.factor(box_data$Zip)

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

# Shannon Entropy function
shannon_entropy <- function(row) {
  prob <- row / sum(row)
  prob <- prob[prob > 0]
  -sum(prob * log2(prob))
}

# Compute entropy
SE <- apply(dem_norm[, 2:7], 1, shannon_entropy)

# Create data frame 'df' with required columns
df <- data.frame(freq_tbl$Freq, sub_COIs[, 25:28], SE)
colnames(df) <- c('n_books', 'r_ed_nat', 'r_he_nat', 'r_se_nat', 'r_coi_nat', 's_entropy')
rownames(df) <- dem_norm$zip

dem_norm$SE <- SE

# Filter and sort spatial data to include only zip codes in bookbox table
sub_zc <- zc_spatial %>%
  filter(zc_spatial$ZCTA5CE10 %in% u_zips)

sub_z_srt = sub_zc %>%
  arrange(ZCTA5CE10)

# Define UI for the Shiny app
ui <- fluidPage(
  titlePanel("Interactive Book Box Density Map"),
  
  # Use absolutePanel to position the dropdown on the right side
  absolutePanel(
    top = 10, right = 10, width = 300,  # Adjust positioning as needed
    draggable = TRUE,  # Allow the user to drag the panel
    style = "z-index: 1000;",  # Ensure it appears on top of other elements
    
    # Dropdown menu to select the column for coloring the borders
    selectInput("color_by", "Select Variable to Color Zip Borders By:",
                choices = c("Number of Books" = "n_books", 
                            "Education Rate" = "r_ed_nat", 
                            "Health Rate" = "r_he_nat", 
                            "Service Rate" = "r_se_nat", 
                            "COI Rate" = "r_coi_nat", 
                            "Shannon Entropy" = "s_entropy"),
                selected = "n_books"),
    
    # Checkbox for showing bookbox locations
    checkboxInput("show_boxes", "Show Bookbox Locations", value = FALSE),
    
    # Dropdown menu for coloring bookbox locations
    conditionalPanel(
      condition = "input.show_boxes == true",
      selectInput("color_boxes_by", "Select Variable to Color Bookbox Locations By:",
                  choices = c("Number of Books" = "n_books", 
                              "Education Rate" = "r_ed_nat", 
                              "Health Rate" = "r_he_nat", 
                              "Service Rate" = "r_se_nat", 
                              "COI Rate" = "r_coi_nat", 
                              "Shannon Entropy" = "s_entropy"),
                  selected = "n_books")
    )
  ),
  
  # Main panel to display the Leaflet map
  mainPanel(
    leafletOutput("mymap", width = "100%", height = "500px")  # Adjust height if needed
  )
)

# Define server logic required to draw the map
server <- function(input, output, session) {
  
  # Reactive palette based on the selected variable for polygons
  pal <- reactive({
    colorNumeric(palette = "Reds", domain = df[[input$color_by]])
  })
  
  # Reactive palette for bookbox locations
  box_pal <- reactive({
    colorFactor(palette = "Blues", domain = df[[input$color_boxes_by]])
  })
  
  # Save the map's zoom and bounds to maintain state during updates
  zoom_and_bounds <- reactiveValues(zoom = 10, bounds = NULL)
  
  # Capture zoom and bounds on map interaction
  observeEvent(input$mymap_zoom, {
    zoom_and_bounds$zoom <- input$mymap_zoom
  })
  observeEvent(input$mymap_bounds, {
    zoom_and_bounds$bounds <- input$mymap_bounds
  })
  
  # Render Leaflet map (initial setup)
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -84.39, lat = 33.749, zoom = zoom_and_bounds$zoom) %>%
      addPolygons(data = sub_z_srt,
                  fillColor = ~pal()(df[[input$color_by]]),
                  fillOpacity = 0.75,
                  color = "black",
                  weight = 2,
                  popup = ~paste("Zip Code:", sub_z_srt$ZCTA5CE10, "<br>",
                                 input$color_by, ":", df[[input$color_by]])) %>%
      addMiniMap(toggleDisplay = TRUE, position = "bottomleft")  # Moved minimap to bottom left
  })
  
  # Observer for updating polygons and markers
  observe({
    colorBy <- input$color_by
    box_color_by <- input$color_boxes_by
    
    # Update polygons without clearing them when toggling markers
    leafletProxy("mymap", data = sub_z_srt) %>%
      clearShapes() %>%  # Clear only polygons, not markers
      addPolygons(data = sub_z_srt,
                  fillColor = ~pal()(df[[colorBy]]),
                  fillOpacity = 0.75,
                  color = "black",
                  weight = 2,
                  popup = ~paste("Zip Code:", sub_z_srt$ZCTA5CE10, "<br>",
                                 colorBy, ":", df[[colorBy]])) %>%
      removeControl("colorLegend") %>%
      addLegend(pal = pal(), values = df[[colorBy]], title = colorBy,
                position = "bottomright", layerId = "colorLegend")
    
    # Update bookbox circles if "show_boxes" is checked
    if (input$show_boxes) {
      leafletProxy("mymap", data = box_data) %>%
        clearMarkers() %>%  # Only clear markers, not shapes
        addCircles(lng = ~Longitude, lat = ~Latitude,
                   radius = 50,
                   fillColor = ~box_pal()(df[[box_color_by]]),
                   fillOpacity = 0.7,
                   color = "black",
                   popup = ~paste("Street:", box_data$Street, "<br>",
                                  "Zip Code:", box_data$Zip, "<br>",
                                  box_color_by, ":", df[[box_color_by]])) %>%
        removeControl("boxLegend") %>%
        addLegend(pal = box_pal(), values = df[[box_color_by]], 
                  title = box_color_by, position = "bottomleft", layerId = "boxLegend")
    } else {
      leafletProxy("mymap") %>%
        clearMarkers() %>%  # Clear only markers when toggling off
        removeControl("boxLegend")
    }
  })
}


# Run the Shiny app
shinyApp(ui = ui, server = server)
