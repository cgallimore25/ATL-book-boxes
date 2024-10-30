## Module for palette buttons
paletteButtonUI <- function(id) {
  ns <- NS(id)  # Create a namespace
  
  div(style = "position: absolute; bottom: 20px; right: 20px; display: flex; flex-direction: column; align-items: flex-start;",
      # Title above the buttons
      h5(style = "margin-left: 20px;","Change Box Color Scheme"),
      div(style = "display: flex;",
          tags$button(
            id = ns("c1_bttn"),
            class = "btn action-button",
            tags$img(src = "cividis.png", height = "50px")  # Path remains the same
          ),
          tags$button(
            id = ns("c2_bttn"),
            class = "btn action-button",
            tags$img(src = "mako.png", height = "50px")     # Path remains the same
          ),
          tags$button(
            id = ns("c3_bttn"),
            class = "btn action-button",
            tags$img(src = "rocket.png", height = "50px")   # Path remains the same
          )
      )
  )
}
