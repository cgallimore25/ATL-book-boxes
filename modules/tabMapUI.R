## Module for the interactive map tab

tabMapUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  # Detect device type
  # mobileDetect(ns('isMobile'))
  
  fluidPage(
    # Make height adaptable to screen, bring drop-downs forward
    tags$style(type = "text/css", glue::glue("
      #{ns('map')} {{height: calc(100vh - 80px) !important;}}
      .dropdown-menu {{ z-index: 1050; }} /* Higher z-index for dropdowns */
      .panel {{ z-index: 1000; }}         /* Adjust z-index for the panel */
    ")),
    
    # Data selection panel module (positioned in top-right corner of UI)
    selectionPanelUI(ns("controls")),
    
    # Color palette buttons module (positioned in bottom-right corner of UI)
    paletteButtonUI(ns("palette_buttons")),
    
    # Leaflet map main panel
    mainPanel(
      leafletOutput(ns("map"), width = "100%", height = '100vh')
    ),
    
    # Attribution overlay at the bottom center
    tags$div(style = "position: absolute; bottom: 7.5px; left: 35%; 
             transform: translateX(-50%); color: gray; font-size: 12px;",
             "Data compiled by ", tags$em('Connor Gallimore'))
  )
}






## Previously in place of selectionPanelUI()
# Use absolutePanel to position the dropdown on the right side
# absolutePanel(id = ns("controls"), 
#               class = "panel panel-default", 
#               fixed = TRUE,
#               draggable = TRUE, 
#               top =   60,
#               right = 20,
#               width = 300,
#               # top = if(is_mobile) 10 else 60, 
#               # right = if(is_mobile) 10 else 20, 
#               # width = if(is_mobile) 250 else 300,
#               style = "background-color: #f9f9f9; border: 1px solid lightgray; padding: 15px; border-radius: 8px;",  # Custom styles
#               
#               selectInput(ns("color_zip_by"), "Color Zips By:",
#                           choices = zip_choices, selected = "n_boxes"),
#               materialSwitch(ns("show_zip_brds"), 
#                              label = "Zip Densities", 
#                              value = FALSE, right = TRUE,
#                              status = "primary"),
#               materialSwitch(ns("show_box_locs"), 
#                              label = "Bookbox Locations", 
#                              value = FALSE, right = TRUE,
#                              status = "primary"),
#               
#               selectInput(ns("color_box_by"), "Color Boxes By:",
#                           choices = box_choices, selected = "n_boxes")
# ),