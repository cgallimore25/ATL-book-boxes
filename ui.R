## Define UI for Shiny app

library(shinyWidgets)

ui <- navbarPage("100+ ATL Book Boxes", id = "nav", collapsible = TRUE,
      
      # Include the mobile detection script
      # tags$head(
      #   tags$script(src = "mobile-detect.js")
      # ),
      
      # Map UI module
      tabPanel("Interactive Map", tabMapUI("interactive_map")),
      
      # About UI module
      tabPanel("About", tabAboutUI("about"))                     
)



## Mobile detect attempts
# Detect device type
# tags$head(device_detection_script),
# shinybrowser::detect(),

# Map UI module
# tabPanel("Interactive Map", tabMapUI("interactive_map", uiOutput("dynamic_ui"))), 