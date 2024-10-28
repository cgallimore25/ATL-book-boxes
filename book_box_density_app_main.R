# Clear all
rm(list = ls())

# library(tidyverse)
library(leaflet)
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

# Shannon Entropy function -- for demographic diversity
shannon_entropy <- function(row) {
  prob <- row / sum(row)
  prob <- prob[prob > 0]
  -sum(prob * log2(prob))
}

# Compute diversity
SE <- apply(dem_norm[, 2:7], 1, shannon_entropy)

dem_norm$SE <- SE


# Create data frame 'df' with box count, zip-level COI comps, & demographic diversity
df <- data.frame(freq_tbl$Freq, sub_COIs[, 25:28], SE)
colnames(df) <- c('n_boxes', 'r_ed_nat', 'r_he_nat', 'r_se_nat', 'r_coi_nat', 's_entropy')
# rownames(df) <- dem_norm$zip


# Re-order book box data by zip code and remove NAs
zs_box_data <- box_data[order(box_data$Zip),]

zs_box_data <- zs_box_data %>%
  filter(!is.na(Latitude) & !is.na(Longitude))


# Expand data frame by repeating COI / entropy data for repeat zip codes
expanded_df <- df[rep(seq_len(nrow(df)), times = freq_tbl$Freq), ]
rownames(expanded_df) <- NULL


# Merge for plotting & clean-up empty street numbers
merged_dat <- cbind(zs_box_data, expanded_df)
merged_dat$Number[is.na(merged_dat$Number)] <- ""


# Filter and sort spatial data to include only zip codes in bookbox table
sub_zc <- zc_spatial %>%
  filter(zc_spatial$ZCTA5CE10 %in% u_zips)

sub_z_srt = sub_zc %>%
  arrange(ZCTA5CE10)

# Define some drop-down menu choices for our app
input_choices= c("Number of Boxes" = "n_boxes",
                 "Education Resources" = "r_ed_nat", 
                 "Health & Safety" = "r_he_nat", 
                 "Socioeconomic Factors" = "r_se_nat", 
                 "Composite COI" = "r_coi_nat", 
                 "Community Diversity" = "s_entropy")


# Define UI for the Shiny app
ui <- fluidPage(

  titlePanel("Interactive Book Box Density Map"),
  
  # Use absolutePanel to position the dropdown on the right side
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 60, right = 20, width = 300,
                selectInput("color_by", "Select Variable to Color Map By:",
                            choices = input_choices,
                            selected = "n_boxes"),
                checkboxInput("show_box_locs", "Overlay Bookbox Locations", value = FALSE),
                selectInput("color_box_locs", "Select Variable to Color Bookbox Locations By:",
                            choices = input_choices,
                            selected = "n_boxes")
  ),
  
  # Main panel to display the Leaflet map
  mainPanel(
    leafletOutput("map", width = "100%", height = "800px")  # Adjust height if needed
  )
  
)


# Define server logic required to draw the map
server <- function(input, output, session) {
  
  # Convert inputs to list that can be passed to legend titles
  var_lookup <- setNames(as.list(names(input_choices)), unlist(input_choices))
  
  # Create base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -84.5, lat = 33.75, zoom = 10) %>%
      addMiniMap(tiles = providers$Esri.WorldStreetMap, position = "bottomleft", toggleDisplay = TRUE)
      
  })
  
  # Manage zip borders overlay
  observe({
    color_by <- input$color_by
    colorData <- df[[color_by]]
    pal <- colorBin("Reds", domain = colorData, bins = 7, pretty = FALSE)
    
    leafletProxy("map", data = sub_z_srt) %>%
      clearGroup("zip_borders") %>%             # Clear only the polygon group
      removeControl("bords_legend") %>%         # Clear previous box legend
      addPolygons(fillColor = ~pal(colorData),
                  fillOpacity = 0.7, color = "black", weight = 1, group = "zip_borders") %>%
      addLegend("topright", pal = pal, values = colorData, title = var_lookup[[color_by]], layerId = "bords_legend")
    
  })
  
  # Manage book box markers overlay
  observe({
    if (input$show_box_locs) {
      color_box_locs <- input$color_box_locs
      colorBoxData <- merged_dat[[color_box_locs]]
      pal_pts <- colorBin("viridis", domain = colorBoxData, bins = 7, pretty = FALSE)
      
      # Capture current zoom level to adjust marker size
      zoom_level <- input$map_zoom
      radius <- 110000 * (0.6 ^ zoom_level)  # Scale marker size inversely with zoom level
      
      leafletProxy("map", data = merged_dat) %>%
        clearGroup("book_boxes") %>%            # Clear existing markers
        removeControl("boxes_legend") %>%         # Clear previous box legend
        addCircles(lng = ~Longitude, lat = ~Latitude,
                   radius = radius, color = ~pal_pts(colorBoxData),
                   stroke = FALSE, fillOpacity = 0.8, group = "book_boxes", 
                   popup = ~paste("Latitude:", Latitude, "<br>",
                                  "Longitude:", Longitude, "<br>",
                                  "Address:", paste0(Number, " ", Street, ", ", Zip), "<br>",
                                  var_lookup[[color_box_locs]], ":", colorBoxData) ) %>%
        addLegend("bottomright", pal = pal_pts, values = colorBoxData, title = var_lookup[[color_box_locs]], layerId = "boxes_legend")
      
    } else {
      leafletProxy("map") %>%
        clearGroup("book_boxes") %>%
        removeControl(layerId = "boxes_legend")
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

