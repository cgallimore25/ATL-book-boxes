## Module Server for control panel
# observe toggle and drop-down states

controlPanelServer <- function(id, map_inputs) {
  moduleServer(id, function(input, output, session) {
    
    # Observe input states, update reactive values
    observe({
      map_inputs$show_zip_brds <- input$show_zip_brds %||% FALSE
      map_inputs$show_box_locs <- input$show_box_locs %||% FALSE
      map_inputs$color_zip_by <- input$color_zip_by %||% "n_boxes"
      map_inputs$color_box_by <- input$color_box_by %||% "n_boxes"
    })
    
    # Ensure polygon render
    session$onFlushed(function() {
      updateMaterialSwitch(session, "show_zip_brds", value = TRUE)  # Force TRUE
    })
    
  })
}
