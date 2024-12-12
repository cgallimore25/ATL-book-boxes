## Define server for Shiny app

server <- function(input, output, session) {
  
  # Call Map server module
  tabMapServer("interactive_map", n_bins, var_lookup, zip_df, sub_z_srt, merged_dat)
}



## Mobile detect attempts
# Cache the device type at run time
# observeEvent(input$is_mobile, {
#   session$userData$is_mobile <- input$is_mobile
# }, once = TRUE)  

# Dynamically generate the map UI based on device type
# output$dynamic_ui <- renderUI({
#   req(session$userData$is_mobile)  # Ensure `is_mobile` is available
#   tabMapUI("interactive_map", is_mobile = session$userData$is_mobile)
# })

# print(shinybrowser::get_device())

# output$dynamic_ui <- renderUI({
#   tabMapUI("interactive_map", is_mobile = shinybrowser::get_device() == "Mobile")
# })
