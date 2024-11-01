## Define server for Shiny app

server <- function(input, output, session) {
  
  # Call Map server module
  tabMapServer("interactive_map", n_bins, var_lookup, zip_df, sub_z_srt, merged_dat)
}