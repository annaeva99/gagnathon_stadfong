pacman::p_load( data.table, tidyr, gmapsdistance, tidyverse, ggmap, osmdata, maps, leaflet, widgetframe, sf, shiny, geosphere)

hnit_rvk <- fread("data/stofnanir_rvk_hnit.csv") %>% as_tibble()

leaflet(hnit_rvk) %>% addTiles() %>%
  addCircleMarkers(lng = ~E_HNIT_WGS84, lat = ~N_HNIT_WGS84, 
                   popup = ~Stofnun)



hnit_rvk %>% select(long, lat) %>% as.matrix()


### hallo