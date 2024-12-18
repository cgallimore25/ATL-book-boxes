## Module Server for palette buttons
# observe for clicks and create a pair of color palettes based on button choice

paletteButtonServer <- function(id, palettes, num_bins = 7) {
  moduleServer(id, function(input, output, session) {
    
    # Observe each button and update palettes accordingly
    observeEvent(input$c1_bttn, {
      palettes$selected_palette <- "cividis"
      palettes$box_pal <- viridis::viridis(num_bins, option = "cividis")
      palettes$zip_pal <- "Reds"  
    })
    
    observeEvent(input$c2_bttn, {
      palettes$selected_palette <- "mako"
      full_palette <- viridis::viridis(num_bins + 1, option = "mako")  # n+1 colors
      palettes$box_pal <- full_palette[-(num_bins + 1)]                # Remove brightest color
      palettes$zip_pal <- "Reds"
    })
    
    observeEvent(input$c3_bttn, {
      palettes$selected_palette <- "rocket"
      full_palette <- viridis::viridis(num_bins + 1, option = "rocket")
      palettes$box_pal <- full_palette[-(num_bins + 1)]  
      palettes$zip_pal <- "Blues"  
    })
    
  })
}

