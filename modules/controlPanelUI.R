## Module UI for data control panel
# dynamically renders panel based on mobile detection

controlPanelUI <- function(id, map_inputs, is_mobile) {
  ns <- NS(id)  # Create a namespace
  
  # Position and properties based on mobile detection
  panel_config <- list(
    id = ns("controls"), 
    class = ifelse(is_mobile, "panel panel-default mobile-panel", "panel panel-default"),
    fixed = TRUE,
    draggable = TRUE,
    top = if (is_mobile) 80 else 60,
    right = if (!is_mobile) 20 else NULL,
    left = if (is_mobile) 10 else NULL,
    width = if (is_mobile) 175 else 300, # 300 for desktop
    style = if (is_mobile) {
      "background-color: #f9f9f9; 
      border: 1px solid lightgray; 
      padding: 10px; 
      border-radius: 8px; 
      opacity: 0.6; 
      transition: opacity 500ms 500ms;"
    } else {
      "background-color: #f9f9f9; 
      border: 1px solid lightgray; 
      padding: 15px; 
      border-radius: 8px; 
      opacity: 0.9;"
    }
  )
  
  # Hover style as an inline attribute if mobile
  if (is_mobile) {
    panel_config$`data-hover-style` <- sprintf(
      "opacity: 0.9; transition-delay: 0s;"
    )
  }
  
  # Create the absolute panel
  selection_panel <- do.call(absolutePanel, c(
    panel_config,
    list(
      selectInput(ns("color_zip_by"), "Color Zips By:",
                  choices = zip_choices, selected = map_inputs$color_zip_by),
      materialSwitch(ns("show_zip_brds"), 
                     label = "Zip Densities", 
                     value = map_inputs$show_zip_brds, right = TRUE,
                     status = "primary"),
      materialSwitch(ns("show_box_locs"), 
                     label = "Box Locations", 
                     value = map_inputs$show_box_locs, right = TRUE,
                     status = "primary"),
      selectInput(ns("color_box_by"), "Color Boxes By:",
                  choices = box_choices, selected = map_inputs$color_box_by)
    )
  ))
  
  # Add head style for hover if mobile
  if (is_mobile) {
    selection_panel <- tagAppendChild(
      selection_panel, 
      tags$style(
        type = "text/css", 
        HTML(sprintf("#%s { 
          transition: opacity 0.3s ease; 
        }
        #%s:hover { 
          opacity: 0.9 !important; 
          transition-delay: 0s !important; 
        }", ns('controls'), ns('controls')))
      )
    )
  }
  
  selection_panel
}
