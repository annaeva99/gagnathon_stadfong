pacman::p_load(arrow, data.table, tidyr, tidyverse, leaflet, sf)

hnit_rvk <- fread("data/stofnanir_rvk_hnit.csv") %>% as_tibble() %>% drop_na(Stofnun)
opnirreikningar_rvk <- read_parquet("data/opnirreikningar_rvk_hnit.parquet")


### Shiny app sem sýnir á korti kaupendur fyrir hvern birgi ###


# Create an empty data frame to store LineStrings

opnirreikningar_rvk <- opnirreikningar_rvk %>% mutate(year = year(dags_greidslu))
opnirreikningar_rvk_sf <- st_as_sf(opnirreikningar_rvk, coords = c("long", "lat"), crs = 4326)


#opnirreikningar_dist <- st_distance(opnirreikningar_rvk_sf)

library(shiny)
library(dplyr)
library(RColorBrewer)
library(scales)

ui <- fluidPage(
  titlePanel("Landfræðileg greining á kaupendum"),
  sidebarLayout(
    sidebarPanel(
      # Add input for selecting a company and year
      selectInput("birgi", "Veldu birgi", choices = unique(opnirreikningar_rvk$birgi)),
      selectInput("year", "Veldu ár", c("Öll", unique(opnirreikningar_rvk$year))) 
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
    df_filtered <- subset(opnirreikningar_rvk_sf, birgi == input$birgi)
    if (input$year != "Öll") {
      df_filtered <- df_filtered[df_filtered$year == as.numeric(input$year), ]
    }
    
    df_aggregated <- df_filtered %>%
      group_by(kaupandi, geometry) %>%
      summarize(total_spent = sum(upphaed_linu))
    df_aggregated
  })
  
  # Create the Leaflet map
  output$map <- renderLeaflet({

      leaflet() %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addProviderTiles(providers$Stamen.TonerLines,
                       options = providerTileOptions(opacity = 0.35)) %>% 
      addCircleMarkers(data = filtered_data(),
                      label = ~paste(kaupandi, " - Útgjöld:", total_spent),
                      radius = 8,
                      fillOpacity = 1,
                      color = ~colorNumeric("RdYlBu", domain = c(min(filtered_data()$total_spent), max(filtered_data()$total_spent)), reverse = TRUE)(total_spent)) 
    
    
  })
}

shinyApp(ui, server)
