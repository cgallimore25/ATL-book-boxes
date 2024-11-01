## Define UI for Shiny app

library(shinyWidgets)

ui <- navbarPage("100+ ATL Book Boxes", id = "nav",
                 
      tabPanel("Interactive Map", tabMapUI("interactive_map")),  # Map UI module
      tabPanel("About", tabAboutUI("about"))                     # About UI module
)

