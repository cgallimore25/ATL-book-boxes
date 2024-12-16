## Module for interactive map tab UI

tabMapUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  fluidPage(

    # Specify map height and arrange z-indices of rendered elements
    tags$style(type = "text/css", glue::glue("
      #{ns('map')} {{height: calc(100vh - 80px) !important; z-index: 1000; padding: 0; margin: 0;}}
      div[id$='control_panel'] {{ z-index: 1050; position: absolute; }} /* Adjust z-index for the panel */
      .attribution-overlay {{ z-index: 1100; position: absolute; }} /* Ensure overlay is on top */
      .palette-buttons {{ z-index: 1040; }}
    ")),
    
    # Detect device type and define placeholder UIs
    mobileDetect('isMobile'),
    uiOutput(ns("control_panel")),
    uiOutput(ns("palette_buttons")),
    
    # Leaflet map main panel
    mainPanel(
      style = "padding: 0; margin: 0;",
      leafletOutput(ns("map"), width = "100%", height = '100vh')
    ),
    
    # Attribution overlay at the bottom center
    tags$div(class = "attribution-overlay",
             style = "bottom: 1vh; left: 30%; transform: translateX(-50%); 
                      width: auto; color: darkslategray; font-size: 10px;",
             "Data compiled by ", tags$em('Connor Gallimore'))
  )
}