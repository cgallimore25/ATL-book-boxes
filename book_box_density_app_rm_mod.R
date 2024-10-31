# Clear all
rm(list = ls())

library(viridisLite)
library(viridis)
library(leaflet)
library(shiny)
library(shinyWidgets)

# Get data
source("global.R")

# Load modules
source("modules/paletteButtonUI.R")
source("modules/paletteButtonServer.R")
# source("modules/tabMapUI.R")
# source("modules/tabAboutUI.R")
# source("modules/tabMapServer.R")


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

n_bins <- 7


# Define UI for the Shiny app
ui <- navbarPage("100+ ATL Book Boxes", id = "nav",
   tabPanel("Interactive Map",
            fluidPage(
              # Make height adaptable to screen
              tags$style(type = "text/css", "
                #map {height: calc(100vh - 80px) !important;}
                .dropdown-menu { z-index: 1050; } /* Higher z-index for dropdowns */
                .panel { z-index: 1000; } /* Adjust z-index for the panel */
                "),
            
              # Use absolutePanel to position the dropdown on the right side
              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                            draggable = TRUE, top = 70, right = 20, width = 300,
                            style = "background-color: #f9f9f9; border: 1px solid lightgray; 
                                    padding: 15px; border-radius: 8px;",  # Custom styles
                            selectInput("color_zip_by", "Color Zip Borders By:",
                                        choices = zip_choices,
                                        selected = "n_boxes"),
                            materialSwitch("show_zip_brds", 
                                           label = "Zip Densities", 
                                           value = TRUE, right = TRUE,
                                           status = "primary"),
                            materialSwitch("show_box_locs", 
                                           label = "Bookbox Locations", 
                                           value = FALSE, right = TRUE,
                                           status = "primary"),
                            selectInput("color_box_by", "Color Bookbox Locations By:",
                                        choices = box_choices,
                                        selected = "n_boxes")
            ),
            
            # Color palette buttons positioned in bottom-right corner
            paletteButtonUI("palette_buttons"),
            
            # Leaflet map main panel
            mainPanel(
              leafletOutput("map", width = "100%", height = '100vh')  # Adjust height if needed
            ),
            
            # Attribution overlay at the bottom center with smaller text
            tags$div(style = "position: absolute; bottom: 7.5px; left: 30%; transform: translateX(-50%); color: gray; font-size: 12px;",
                     "Data compiled by ", tags$em('Connor Gallimore')
            )
          )
   ),
   
   tabPanel("About",
            fluidPage(
              h4("Inspiration"),
              p("This project was inspired by my observation that many of the public bookcases in my area were not listed on the Little Free Library web map.
                 From 2023-2024, I recorded longitude and latitude coordinates for the ones I discovered, and cross-referenced them with the listings, culminating in this dataset of 105 bookboxes in the Greater Atlanta area."),
              
              h4("The Child Opportunity Index"),
              p("Being interested in indicators and issues of health, education, safety, and socioeconomic inequity, I incorporated nationally normalized zip code estimates from the Child Opportunity Index (COI; link).
                 The COI is a composite index of children's neighborhood opportunity, consisting of 3 major domains: Education (ED), Health and Environment (HE), and Social and Economic factors (SE)."),
              
              h4("Explanation of variables:"),
              tags$ul(
                tags$li("Book Box Locations: Collected from community engagement."),
                tags$li("Community of Interest (COI) Data: Provided by relevant social services."),
                tags$li("Demographic Data: Sourced from the U.S. Census Bureau.")
              ),
              
              h4("Usage"),
              p("Hovering over plotted zip codes highlights their borders. 
                 Clicking any border shows the zip code and value of the color variable. 
                 Clicking book box locations shows their coordinates, address, and value of the color variable.
                 Border and box location colors are disentangled, allowing visualization of different COI scores alongside the distribution of boxes.
                 Toggle different color schemes by clicking the palettes. Happy hunting, bookworms :)"),
              
              hr(),
              h4("Additional Information"),
              p("This project aims to foster community awareness and promote resource sharing through an engaging and informative interface.")
            )
     )
)


server <- function(input, output, session) {
  
   # Convert zip/box choices to list that can be passed to legend titles
   var_lookup <- setNames(as.list(names(box_choices)), unlist(box_choices))
  
   # Reactive palettes for map layers
   palettes <- reactiveValues(selected_palette = "cividis", 
                              zip_pal = "Reds",     
                              box_pal = viridis::viridis(n_bins, option = "cividis"))  
   
   # Manage color palette buttons with the paletteButtonServer module
   paletteButtonServer("palette_buttons", palettes, num_bins = n_bins)
  
   # Create base map
   output$map <- renderLeaflet({
     leaflet() %>%
       addTiles() %>%
       setView(lng = -84.5, lat = 33.75, zoom = 10) %>%
       addMiniMap(tiles = providers$Esri.WorldStreetMap, position = "bottomleft", toggleDisplay = TRUE)
   })
   
   # Manage zip borders overlay
   observe({
     if (input$show_zip_brds) {
       color_zip_by <- input$color_zip_by
       zip_cdata <- zip_df[[color_zip_by]]
       pal <- colorBin(palettes$zip_pal, domain = zip_cdata, bins = n_bins, pretty = FALSE)
       
       h_opts <- highlightOptions(color = "black", weight = 2, bringToFront = FALSE, fillOpacity = 0.9)
       
       leafletProxy("map", data = sub_z_srt) %>%
         clearGroup("zip_borders") %>%
         removeControl("bords_legend") %>%
         addPolygons(fillColor = ~pal(zip_cdata), fillOpacity = 0.7, color = "black", weight = 1, group = "zip_borders",
                     highlightOptions = h_opts,
                     popup = ~paste("Zip:", ZCTA5CE10, "<br>", var_lookup[[color_zip_by]], ":", zip_cdata)) %>%
         addLegend("topright", pal = pal, values = zip_cdata, title = var_lookup[[color_zip_by]], layerId = "bords_legend", labFormat = labelFormat(digits = 1))
     } else {
       leafletProxy("map") %>%
         clearGroup("zip_borders") %>%
         removeControl("bords_legend")
     }
   })
   
   # Manage book box markers overlay
   observe({
     if (input$show_box_locs) {
       color_box_by <- input$color_box_by
       box_cdata <- merged_dat[[color_box_by]]
       pal_pts <- if (color_box_by %in% c("self_c", "charted")) colorFactor(palettes$box_pal, box_cdata) else colorBin(palettes$box_pal, domain = box_cdata, pretty = FALSE)
       
       zoom_level <- input$map_zoom
       radius <- 110000 * (0.6 ^ zoom_level)
       
       leafletProxy("map", data = merged_dat) %>%
         clearGroup("book_boxes") %>%
         removeControl("boxes_legend") %>%
         addCircles(lng = ~Longitude, lat = ~Latitude, radius = radius, color = ~pal_pts(box_cdata),
                    stroke = FALSE, fillOpacity = 0.8, group = "book_boxes",
                    popup = ~paste("Latitude:", Latitude, "<br>", "Longitude:", Longitude, "<br>", "Address:", paste0(Number, " ", Street, ", ", Zip), "<br>", var_lookup[[color_box_by]], ":", box_cdata)) %>%
         addLegend("bottomright", pal = pal_pts, values = box_cdata, title = var_lookup[[color_box_by]], layerId = "boxes_legend", labFormat = labelFormat(digits = 1))
     } else {
       leafletProxy("map") %>%
         clearGroup("book_boxes") %>%
         removeControl("boxes_legend")
     }
   })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

