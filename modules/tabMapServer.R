## Server module for managing interactive map

tabMapServer <- function(id, n_bins, var_lookup, zip_df, sub_z_srt, merged_dat) {
  moduleServer(id, function(input, output, session) {
    
    # Initialize default toggle & palette states as reactive values
    map_inputs <- reactiveValues(
      show_zip_brds = TRUE,
      show_box_locs = FALSE,
      color_zip_by = "n_boxes",
      color_box_by = "n_boxes"
    )
    
    palettes <- reactiveValues(
      selected_palette = "cividis", 
      zip_pal = "Reds",     
      box_pal = viridis::viridis(n_bins, option = "cividis")
    )
    
    # Render controls panel based on mobile detection
    output$control_panel <- renderUI({
      controlPanelUI(session$ns("control_panel"), map_inputs, TRUE) # isTRUE(input$isMobile))  # is_mobile
    })
    
    # Render palette buttons 
    output$palette_buttons <- renderUI({
      paletteButtonUI(session$ns("palette_buttons"), TRUE) # isTRUE(input$isMobile))
    })
    
    
    # Manage control toggle states with input observer module
    controlPanelServer("control_panel", map_inputs)
    
    # Manage color palette buttons with button observer module
    paletteButtonServer("palette_buttons", palettes, num_bins = n_bins)
    
    # Create base map
    output$map <- renderLeaflet({
      is_mobile <- TRUE # isTRUE(input$isMobile)
      
      base_map <- if (is_mobile) {
        leaflet(options = leafletOptions(zoomControl = FALSE))
      } else {
        leaflet()
      }
      
      base_map %>%  
      addTiles() %>%
        setView(lng = -84.4, lat = 33.75, zoom = 10) %>%
        addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
        addMapPane("circles", zIndex = 440) %>%         # Level 3: top
        addMiniMap(tiles = providers$Esri.WorldStreetMap, 
                   position = "bottomleft",
                   width = 80, height= 80, 
                   toggleDisplay = TRUE,
                   minimized = TRUE)
    })
    

    # Manage zip borders overlay------------------------------------------------
    observe({
      if (map_inputs$show_zip_brds) {
        color_zip_by <- map_inputs$color_zip_by
        zip_cdata <- zip_df[[color_zip_by]]
        pal <- colorBin(palettes$zip_pal, domain = zip_cdata, bins = n_bins, pretty = FALSE)
        
        h_opts <- highlightOptions(color = "black", weight = 2, bringToFront = FALSE, fillOpacity = 0.8)
        
        leafletProxy("map", data = sub_z_srt) %>%
          clearGroup("zip_borders") %>%
          removeControl("bords_legend") %>%
          addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
          addPolygons(fillColor = ~pal(zip_cdata), fillOpacity = 0.65, 
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
          addMapPane("circles", zIndex = 440) %>%          # Level 3: top
          addCircles(lng = ~Longitude, lat = ~Latitude, radius = radius, 
                     color = ~pal_pts(box_cdata), stroke = FALSE,
                     group = "book_boxes", fillOpacity = 0.8, 
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
