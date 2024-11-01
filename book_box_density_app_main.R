# Clear all
rm(list = ls())

library(shinyWidgets)

# Get data
source("global.R")


# Define UI for the Shiny app
ui <- navbarPage("100+ ATL Book Boxes", id = "nav",
                 
   tabPanel("Interactive Map", tabMapUI("interactive_map")),  # Map UI module
   tabPanel("About", tabAboutUI("about"))                     # About UI module
)


server <- function(input, output, session) {
  
  # Call Map server module
  tabMapServer("interactive_map", n_bins, var_lookup, zip_df, sub_z_srt, merged_dat)
}

shinyApp(ui = ui, server = server)

