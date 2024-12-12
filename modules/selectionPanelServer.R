

selectionPanelServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # Ensure polygon render
    session$onFlushed(function() {
      updateMaterialSwitch(session, ns("show_zip_brds"), value = TRUE)   # Set back to TRUE
    })
    
    output$selection_panel <- renderUI({
        absolutePanel(id = id, 
                      class = "panel panel-default", 
                      fixed = TRUE,
                      draggable = TRUE, 
                      top =   60,
                      right = 20,
                      width = 300,
                      # top = if(is_mobile) 10 else 60, 
                      # right = if(is_mobile) 10 else 20, 
                      # width = if(is_mobile) 250 else 300,
                      style = "background-color: #f9f9f9; border: 1px solid lightgray; padding: 15px; border-radius: 8px;",  # Custom styles
                      
                      selectInput(ns("color_zip_by"), "Color Zips By:",
                                  choices = zip_choices, selected = "n_boxes"),
                      materialSwitch(ns("show_zip_brds"), 
                                     label = "Zip Densities", 
                                     value = FALSE, right = TRUE,
                                     status = "primary"),
                      materialSwitch(ns("show_box_locs"), 
                                     label = "Bookbox Locations", 
                                     value = FALSE, right = TRUE,
                                     status = "primary"),
                      
                      selectInput(ns("color_box_by"), "Color Boxes By:",
                                  choices = box_choices, selected = "n_boxes")
        )
      
      color_zip_by <- reactive(input$color_zip_by)
      show_zip_brds <- reactive(input$show_zip_brds)
      show_box_locs <- reactive(input$show_box_locs)
      color_box_by <- reactive(input$color_box_by)

      return(color_zip_by())
      return(show_zip_brds())
      return(show_box_locs())
      return(color_box_by())
    })
    
  })
}