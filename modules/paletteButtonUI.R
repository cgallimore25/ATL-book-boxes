## Module for palette buttons

paletteButtonUI <- function(id) {
  ns <- NS(id)  # Create a namespace
  
  div(style = "position: absolute; bottom: 20px; right: 20px; 
               display: flex; flex-direction: column; align-items: flex-start;",
      
      # Title above the buttons
      h5(style = "margin-left: 15px;", "Change Box Color Scheme"),
      div(style = "display: flex;",
          actionButton(inputId = ns("c1_bttn"), label = tags$img(src = "cividis.png", height = "45px")),
          actionButton(inputId = ns("c2_bttn"), label = tags$img(src = "mako.png", height = "45px")),
          actionButton(inputId = ns("c3_bttn"), label = tags$img(src = "rocket.png", height = "45px"))
      )
  )
}
