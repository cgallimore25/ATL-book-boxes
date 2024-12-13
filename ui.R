## Define UI for Shiny app

library(shinyWidgets)

ui <- navbarPage("100+ ATL Book Boxes", id = "nav", collapsible = TRUE,
      
      # Map UI module
      tabPanel("Interactive Map", tabMapUI("interactive_map")),
      
      # About UI module
      tabPanel("About", tabAboutUI("about"))                     
)
