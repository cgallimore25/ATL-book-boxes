## Module for the interactive map tab

tabMapUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  shinybrowser::detect()
  
  fluidPage(
    
    # Make height adaptable to screen, bring drop-downs forward
    tags$style(type = "text/css", glue::glue("
      #{ns('map')} {{height: calc(100vh - 80px) !important;}}
      .dropdown-menu {{ z-index: 1050; }} /* Higher z-index for dropdowns */
      .panel {{ z-index: 1000; }}         /* Adjust z-index for the panel */
    ")),
    
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


## Detect device type -- before fluid page
# mobileDetect(ns('isMobile'))

## Edits for mobile conditional
# top = if(is_mobile) 10 else 60, 
# right = if(is_mobile) 10 else 20, 
# width = if(is_mobile) 250 else 300,