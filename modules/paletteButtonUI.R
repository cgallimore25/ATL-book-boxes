## Module UI for palette buttons
# create a row of 3 buttons from palette images

paletteButtonUI <- function(id, is_mobile) {
  ns <- NS(id)  # Create a namespace
  
  # Apply conditional formatting for mobile vs desktop
  flex_direction <- if (is_mobile) "column" else "row"
  position_side <- if (is_mobile) "left: 20px;" else "right: 20px;"
  position_vert <- if (is_mobile) "bottom: 45px;" else "bottom: 20px;"
  button_title <- if (is_mobile) "" else "Change Box Color Scheme"
  opacity <- if (is_mobile) "opacity: 0.6;"  else "opacity: 0.6;"
  height <- if (is_mobile) "30px"  else "40px"
  
  div(
    style = glue::glue("
      position: absolute; {position_vert} {position_side};
      display: flex; flex-direction: column; align-items: flex-start;
    "),
      
      # Title above the buttons
      h5(style = "margin-left: 15px;", button_title),
      div(
        class = "palette-buttons",
        style = glue::glue("
        {opacity} display: flex; flex-direction: {flex_direction};
      "), # Make buttons
          actionButton(inputId = ns("c1_bttn"), label = tags$img(src = "cividis.png", height = height)),
          actionButton(inputId = ns("c2_bttn"), label = tags$img(src = "mako.png", height = height)),
          actionButton(inputId = ns("c3_bttn"), label = tags$img(src = "rocket.png", height = height))
      )
  )
}
