## Server module for managing the interactive map

tabMapServer <- function(id, n_bins, var_lookup, zip_df, sub_z_srt, merged_dat) {
  moduleServer(id, function(input, output, session) {
    
    # Fix to ensure polygon render
    session$onFlushed(function() {
      updateMaterialSwitch(session, "show_zip_brds", value = TRUE)   # Set back to TRUE
    })
    
    # Initial reactive palettes for map elements
    palettes <- reactiveValues(
      selected_palette = "cividis", 
      zip_pal = "Reds",     
      box_pal = viridis::viridis(n_bins, option = "cividis")
    )
    
    # Manage color palette buttons with the paletteButtonServer module
    paletteButtonServer("palette_buttons", palettes, num_bins = n_bins)
    
    # Create base map
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        setView(lng = -84.4, lat = 33.75, zoom = 10) %>%
        addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
        addMapPane("circles", zIndex = 430) %>%         # Level 3: top
        addMiniMap(tiles = providers$Esri.WorldStreetMap, position = "bottomleft", toggleDisplay = TRUE)
    })
    
    # Manage zip borders overlay------------------------------------------------
    observe({
      if (input$show_zip_brds) {
        color_zip_by <- input$color_zip_by
        zip_cdata <- zip_df[[color_zip_by]]
        pal <- colorBin(palettes$zip_pal, domain = zip_cdata, bins = n_bins, pretty = FALSE)
        
        h_opts <- highlightOptions(color = "black", weight = 2, bringToFront = FALSE, fillOpacity = 0.9)
        
        leafletProxy("map", data = sub_z_srt) %>%
          clearGroup("zip_borders") %>%
          removeControl("bords_legend") %>%
          addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
          addPolygons(fillColor = ~pal(zip_cdata), fillOpacity = 0.7, color = "black", weight = 1, group = "zip_borders",
                      highlightOptions = h_opts,
                      popup = ~paste("Zip:", ZCTA5CE10, "<br>", var_lookup[[color_zip_by]], ":", zip_cdata)) %>%
          addLegend("topright", pal = pal, values = zip_cdata, title = var_lookup[[color_zip_by]], layerId = "bords_legend", labFormat = labelFormat(digits = 1))
      } else {
        leafletProxy("map") %>%
          clearGroup("zip_borders") %>%
          removeControl("bords_legend")
      }
    })
    
    # Manage book box markers overlay-------------------------------------------
    observe({
      if (input$show_box_locs) {
        color_box_by <- input$color_box_by
        box_cdata <- merged_dat[[color_box_by]]
        pal_pts <- if (color_box_by %in% c("self_c", "charted")) colorFactor(palettes$box_pal, box_cdata) else colorBin(palettes$box_pal, domain = box_cdata, pretty = FALSE)
        
        zoom_level <- input$map_zoom
        radius <- 110000 * (0.6 ^ zoom_level)
        
        leafletProxy("map", data = merged_dat) %>%
          clearGroup("book_boxes") %>%
          removeControl("boxes_legend") %>%
          addMapPane("circles", zIndex = 430) %>%          # Level 3: top
          addCircles(lng = ~Longitude, lat = ~Latitude, radius = radius, color = ~pal_pts(box_cdata),
                     stroke = FALSE, fillOpacity = 0.8, group = "book_boxes",
                     popup = ~paste("Latitude:", Latitude, "<br>", "Longitude:", Longitude, "<br>", "Address:", paste0(Number, " ", Street, ", ", Zip), "<br>", var_lookup[[color_box_by]], ":", box_cdata)) %>%
          addLegend("bottomright", pal = pal_pts, values = box_cdata, title = var_lookup[[color_box_by]], layerId = "boxes_legend", labFormat = labelFormat(digits = 1))
      } else {
        leafletProxy("map") %>%
          clearGroup("book_boxes") %>%
          removeControl("boxes_legend")
      }
    })
  })
}
