## Module for about tab

tabAboutUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  fluidPage(
    h4("Inspiration"),
    p("This project was inspired by my observation that many of the public bookcases in my area were not listed on the Little Free Library web map.
                 From 2023-2024, I recorded longitude and latitude coordinates for the ones I discovered, and cross-referenced them with the listings, culminating in this dataset of 105 bookboxes in the Greater Atlanta area."),
    
    h4("The Child Opportunity Index"),
    p("Being interested in indicators and issues of health, education, safety, and socioeconomic inequity, I incorporated nationally normalized zip code estimates from the Child Opportunity Index (COI; link).
                 The COI is a composite index of children's neighborhood opportunity, consisting of 3 major domains: Education (ED), Health and Environment (HE), and Social and Economic factors (SE)."),
    
    h4("Explanation of variables:"),
    tags$ul(
      tags$li("Book Box Locations: Collected from community engagement."),
      tags$li("Community of Interest (COI) Data: Provided by relevant social services."),
      tags$li("Demographic Data: Sourced from the U.S. Census Bureau.")
    ),
    
    h4("Usage"),
    p("Hovering over plotted zip codes highlights their borders. 
    Clicking any border shows the zip code and value of the color variable. 
    Clicking book box locations shows their coordinates, address, and value of the color variable.
    Border and box location colors are disentangled, allowing visualization of different COI scores alongside the distribution of boxes.
    Toggle different color schemes by clicking the palettes. Happy hunting, bookworms :)"),

    hr(),
    h4("Additional Information"),
    p("This project aims to foster community awareness and promote resource sharing through an engaging and informative interface.")
  )
}
