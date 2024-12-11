## Define UI for Shiny app

library(shinyWidgets)

ui <- navbarPage("100+ ATL Book Boxes", id = "nav", collapsible = TRUE,
      
      # Detect device type
      # tags$head(device_detection_script),
      # shinybrowser::detect(),
      
      # Map UI module
      # tabPanel("Interactive Map", tabMapUI("interactive_map", uiOutput("dynamic_ui"))), 
      tabPanel("Interactive Map", tabMapUI("interactive_map")),
      
      # About UI module
      tabPanel("About", tabAboutUI("about"))                     
)

