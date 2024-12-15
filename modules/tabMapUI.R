## Module for the interactive map tab

tabMapUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  fluidPage(

    # Make height adaptable to screen, bring drop-downs forward
    tags$style(type = "text/css", glue::glue("
      #{ns('map')} {{height: calc(100vh - 80px) !important; z-index: 1000;}}
      div[id$='control_panel'] {{ z-index: 1010; position: absolute; }} /* Adjust z-index for the panel */
      .dropdown-menu {{ z-index: 1050; }} /* Higher z-index for dropdowns */
      .attribution-overlay {{ z-index: 1100; position: absolute; }} /* Ensure overlay is on top */
      .palette-buttons {{ z-index: 1040; }}
    ")),
    
    mobileDetect('isMobile'),
    
    uiOutput(ns("control_panel")),
    uiOutput(ns("palette_buttons")),
    
    # Leaflet map main panel
    mainPanel(
      leafletOutput(ns("map"), width = "100%", height = '100vh')
    ),
    
    # Attribution overlay at the bottom center
    tags$div(class = "attribution-overlay",
             style = "bottom: 7.5px; left: 30%; transform: translateX(-50%); 
                      color: darkslategray; font-size: 12px;",
             "Data compiled by ", tags$em('Connor Gallimore'))
  )
}
