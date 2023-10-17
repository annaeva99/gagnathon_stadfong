pacman::p_load(arrow, data.table, tidyr, tidyverse, leaflet, sf)

hnit_rvk <- fread("data/stofnanir_rvk_hnit.csv") %>% as_tibble() %>% drop_na(Stofnun)
opnirreikningar_rvk <- read_parquet("data/opnirreikningar_rvk_hnit.parquet")

hnit_opnirreikningar <- st_as_sf(opnirreikningar_rvk, coords = c("long","lat"), remove = FALSE)

coords <- st_coordinates(hnit_opnirreikningar)

# 
# leaflet(hnit_opnirreikningar) %>% addTiles() %>%
#   addCircleMarkers(lng = ~long, lat = ~lat, 
#                    popup = ~kaupandi)

## Shiny app sem sýnir á korti kaupendur fyrir hvern birgi

library(shiny)
library(dplyr)
library(RColorBrewer)

ui <- fluidPage(
  titlePanel("Buyer Map"),
  sidebarLayout(
    sidebarPanel(
      # Add input for selecting a company
      selectInput("birgi", "Select Company", choices = unique(opnirreikningar_rvk$birgi)),
      # You can add more input widgets here if needed
    ),
    mainPanel(
      # Add the Leaflet map output
      leafletOutput("map")
    )
  )
)

server <- function(input, output) {
  # Define a reactive expression to filter data based on selected company
  filtered_data <- reactive({
    df_filtered <- subset(opnirreikningar_rvk, birgi == input$birgi)
    df_aggregated <- df_filtered %>%
      group_by(kaupandi, long, lat) %>%
      summarize(total_spent = sum(upphaed_linu))
    df_aggregated
  })
  
  # Create the Leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = filtered_data(),
                       ~long, ~lat,
                       label = ~paste(kaupandi, "Spent:", total_spent),
                       radius = 8,
                       fillOpacity = 0.7, 
                       color = ~colorNumeric("Spectral", domain = filtered_data()$total_spent)(total_spent))
  })
}

shinyApp(ui, server)
