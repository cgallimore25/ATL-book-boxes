## Server module for managing interactive map

tabMapServer <- function(id, n_bins, var_lookup, zip_df, sub_z_srt, merged_dat) {
  moduleServer(id, function(input, output, session) {
    
    # Mobile device detection reactive -- javascript method
    # is_mobile_device <- reactive({
    #   isTRUE(input$is_mobile_device)
    # })
    
    # shinybrowser method
    # is_mobile_device <- observe({
    #   shinybrowser::get_all_info()
    #   })
    
    is_mobile <- reactiveVal()
    
    observe({
      info <- shinybrowser::get_all_info()
      is_mobile <- is_mobile(info)
      # str(shinybrowser::get_all_info())
      })
      
    
    # Create reactive values to store and manage inputs
    map_inputs <- reactiveValues(
      show_zip_brds = TRUE,
      show_box_locs = FALSE,
      color_zip_by = "n_boxes",
      color_box_by = "n_boxes"
    )
    
    # Dynamically render controls panel based on mobile detection
    output$control_panel <- renderUI({
      
      # Panel configuration based on mobile status
      panel_config <- if (!is.null(info) && info$device == "Mobile") {
        list(
          id = session$ns("controls"), 
          class = "panel panel-default mobile-panel", 
          fixed = TRUE,
          draggable = FALSE, 
          top = NULL,
          right = 0,
          bottom = 0,
          width = NULL,
          style = "background-color: #f9f9f9; border: 1px solid lightgray; padding: 15px; border-radius: 8px; width: 100%;"
        )
      } else {
        list(
          id = session$ns("controls"), 
          class = "panel panel-default", 
          fixed = TRUE,
          draggable = TRUE, 
          top = 60,
          right = 20,
          width = 300,
          style = "background-color: #f9f9f9; border: 1px solid lightgray; padding: 15px; border-radius: 8px;"
        )
      }
      
      # Create the absolute panel with dynamic configuration
      do.call(absolutePanel, c(
        panel_config,
        list(
          selectInput(session$ns("color_zip_by"), "Color Zips By:",
                      choices = zip_choices, selected = map_inputs$color_zip_by),
          materialSwitch(session$ns("show_zip_brds"), 
                         label = "Zip Densities", 
                         value = map_inputs$show_zip_brds, right = TRUE,
                         status = "primary"),
          materialSwitch(session$ns("show_box_locs"), 
                         label = "Bookbox Locations", 
                         value = map_inputs$show_box_locs, right = TRUE,
                         status = "primary"),
          
          selectInput(session$ns("color_box_by"), "Color Boxes By:",
                      choices = box_choices, selected = map_inputs$color_box_by)
        )
      ))
    })
    
    # Observe and update reactive values for inputs
    observe({
      map_inputs$show_zip_brds <- input$show_zip_brds %||% FALSE
      map_inputs$show_box_locs <- input$show_box_locs %||% FALSE
      map_inputs$color_zip_by <- input$color_zip_by %||% "n_boxes"
      map_inputs$color_box_by <- input$color_box_by %||% "n_boxes"
    })
    
    # Ensure polygon render
    session$onFlushed(function() {
      updateMaterialSwitch(session, "show_zip_brds", value = TRUE)   # Set back to TRUE
    })
    
    # Initial reactive palettes for map elements
    palettes <- reactiveValues(
      selected_palette = "cividis", 
      zip_pal = "Reds",     
      box_pal = viridis::viridis(n_bins, option = "cividis")
    )
    
    # Manage color palette buttons with paletteButtonServer module
    paletteButtonServer("palette_buttons", palettes, num_bins = n_bins)
    
    # Create base map
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        setView(lng = -84.4, lat = 33.75, zoom = 10) %>%
        addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
        addMapPane("circles", zIndex = 430) %>%         # Level 3: top
        addMiniMap(tiles = providers$Esri.WorldStreetMap, 
                   position = "bottomleft",
                   width = 100, height= 100, 
                   toggleDisplay = TRUE,
                   minimized = TRUE)
    })
    
    # Manage zip borders overlay------------------------------------------------
    observe({
      if (map_inputs$show_zip_brds) {
        color_zip_by <- map_inputs$color_zip_by
        zip_cdata <- zip_df[[color_zip_by]]
        pal <- colorBin(palettes$zip_pal, domain = zip_cdata, bins = n_bins, pretty = FALSE)
        
        h_opts <- highlightOptions(color = "black", weight = 2, bringToFront = FALSE, fillOpacity = 0.9)
        
        leafletProxy("map", data = sub_z_srt) %>%
          clearGroup("zip_borders") %>%
          removeControl("bords_legend") %>%
          addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
          addPolygons(fillColor = ~pal(zip_cdata), fillOpacity = 0.7, 
                      color = "black", weight = 1, group = "zip_borders",
                      highlightOptions = h_opts,
                      popup = ~paste("Zip:", ZCTA5CE10, "<br>", 
                                     var_lookup[[color_zip_by]], ":", zip_cdata)) %>%
          addLegend("topright", pal = pal, values = zip_cdata, 
                    title = var_lookup[[color_zip_by]], 
                    layerId = "bords_legend", 
                    labFormat = labelFormat(digits = 1))
      } else {
        leafletProxy("map") %>%
          clearGroup("zip_borders") %>%
          removeControl("bords_legend")
      }
    })
    
    # Manage book box markers overlay-------------------------------------------
    observe({
      if (map_inputs$show_box_locs) {
        color_box_by <- map_inputs$color_box_by
        box_cdata <- merged_dat[[color_box_by]]
        pal_pts <- if (color_box_by %in% c("self_c", "charted")) colorFactor(palettes$box_pal, box_cdata) 
                   else colorBin(palettes$box_pal, domain = box_cdata, pretty = FALSE)
        
        zoom_level <- input$map_zoom
        radius <- 110000 * (0.6 ^ zoom_level)
        
        leafletProxy("map", data = merged_dat) %>%
          clearGroup("book_boxes") %>%
          removeControl("boxes_legend") %>%
          addMapPane("circles", zIndex = 430) %>%          # Level 3: top
          addCircles(lng = ~Longitude, lat = ~Latitude, radius = radius, 
                     color = ~pal_pts(box_cdata), stroke = FALSE, 
                     fillOpacity = 0.8, group = "book_boxes",
                     popup = ~paste("Latitude:", Latitude, "<br>", 
                                    "Longitude:", Longitude, "<br>", 
                                    "Address:", paste0(Number, " ", Street, ", ", Zip), "<br>", 
                                    var_lookup[[color_box_by]], ":", box_cdata)) %>%
          addLegend("bottomright", pal = pal_pts, values = box_cdata, 
                    title = var_lookup[[color_box_by]], 
                    layerId = "boxes_legend", 
                    labFormat = labelFormat(digits = 1))
      } else {
        leafletProxy("map") %>%
          clearGroup("book_boxes") %>%
          removeControl("boxes_legend")
      }
    })
  })
}
