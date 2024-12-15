## Define UI for Shiny app

library(shinyWidgets)

ui <- navbarPage("100+ ATL Book Boxes", id = "nav", collapsible = TRUE, 
                 
      tags$head(
        tags$style(HTML("
          .navbar {
            z-index: 1100; /* Set navbar on top */
          }
        "))
      ),
                            
      # Map UI module
      tabPanel("Interactive Map", tabMapUI("interactive_map")),
      
      # About UI module
      tabPanel("About", tabAboutUI("about")) 
      
)
