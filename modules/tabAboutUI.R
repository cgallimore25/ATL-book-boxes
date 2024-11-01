## Module for about tab

tabAboutUI <- function(id) {
  ns <- NS(id)  # Create a namespace for the module
  
  fluidPage(
    
    h3("Inspiration"),
    p("In 2023, I noticed that many of the public bookcases in my area were not listed on the Little Free Library web map.
       I began recording longitude and latitude coordinates for the ones I discovered and cross-referencing them with the listings.
       The result is this dataset of 105 bookboxes in the Greater Atlanta area."),
    
    hr(),
    h4("The Child Opportunity Index"),
    p("With an interest in indicators and issues of health, education, safety, and socioeconomic inequity, I incorporated nationally normalized zip code estimates from the", 
       tags$a(href = "https://www.diversitydatakids.org/child-opportunity-index?_ga=2.130754447.1489633750.1679850921-1316632825.1679594824", "Child Opportunity Index", target = "_blank"), "(COI).
       The COI is a composite index of children's neighborhood opportunity, consisting of 3 major domains: Education (ED), Health and Environment (HE), and Social and Economic factors (SE).
       See how coloring the zip areas and box points by different COI variables relate to the (far from exhaustive) distribution of bookboxes!
       Read below for more details about the variables and functionalities."),
    
    hr(),
    h4("Explanation of variables:"),
    tags$ul(
      tags$li(tags$code("Ed resources"), tags$code("Health, env, safety"), tags$code("Socioeconomic"), "and", tags$code("Composite COI"), "here represent the nationally normalized major domain and composite scores (out of 100).
              Read more about them in the COI 3.0", tags$a(href = "https://data.diversitydatakids.org/dataset/coi30-2010-tracts-child-opportunity-index-3-0-database--2010-census-tracts/resource/0c292d45-8a97-494a-908a-3f937516da3a", "overall", target = "_blank"),  
              "and", tags$a(href= "https://data.diversitydatakids.org/dataset/coi30-2010-tracts-child-opportunity-index-3-0-database--2010-census-tracts/resource/8c7305d8-05f6-494b-bcc9-845b305258e1", "subdomain", target = "_blank"), "data dictionaries."),
      tags$li(tags$code("Community diversity"), "is an entropy calculation of the American Indian/Alaska Native, Asian/Pacific Islander, Black, White, Hispanic, and Other as proportions of that zip code's population (also contained in the COI dataset). 
              Higher values indicate a more uniform community composition; low values suggest one/few groups represent most people."),
      tags$li(tags$code("Self-collected"), "and", tags$code("Online"), "are categorical 'yes'/'no' variables of whether I logged the coordinates of a bookbox in-person, and whether the box was previously mapped online.")
    ),
    
    h4("Usage"),
    p("Hovering over plotted zip codes highlights their borders. 
    Clicking any border shows the zip code and value of the color variable. 
    Clicking box locations shows their coordinates, address, and value of the color variable.
    Border and box location colors are disentangled, allowing visualization of different COI scores alongside the distribution of boxes.
    Toggle different color schemes by clicking the palettes. Happy hunting, bookworms :)"),

    hr(),
    h4("Additional Information"),
    p("If the app has bugs, OR you find more Atlanta bookboxes, feel free to contact me at", tags$a(href = "mailto:cggallimore@gmail.com", "cggallimore@gmail.com"))
  )
}
