## Module for the interactive map tab

tabMapUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  fluidPage(
    
    # Make height adaptable to screen, bring drop-downs forward
    tags$style(type = "text/css", glue::glue("
      #{ns('map')} {{height: calc(100vh - 80px) !important; z-index: 1000;}}
      .dropdown-menu {{ z-index: 1050; }} /* Higher z-index for dropdowns */
      .panel {{ z-index: 1010; }}         /* Adjust z-index for the panel */
    ")),
    
    mobileDetect('isMobile'),
    
    uiOutput(ns("control_panel")),
    
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
