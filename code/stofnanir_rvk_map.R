pacman::p_load( data.table, tidyr, gmapsdistance, tidyverse, ggmap, osmdata, maps, leaflet, widgetframe, sf, shiny, geosphere)

hnit_rvk <- fread("data/stofnanir_rvk_hnit.csv") %>% as_tibble()

leaflet(hnit_rvk) %>% addTiles() %>%
  addCircleMarkers(lng = ~E_HNIT_WGS84, lat = ~N_HNIT_WGS84, 
                   popup = ~Stofnun)



hnit_rvk %>% select(long, lat) %>% as.matrix()

ans <- as.data.frame(distm(hnit_rvk %>% select(long, lat) %>% as.matrix(), hnit_rvk %>% select(long, lat) %>% as.matrix(), fun=distHaversine)) 

desired <- ans %>%
  gather(pos1, distance) %>%
  mutate(pos2 = rep(hnit_rvk$Stofnun, nrow(hnit_rvk))) %>%
  filter(pos1!=pos2) %>%
  select(pos1, pos2, distance)

distHaversine(hnit_rvk %>% select(long, lat) %>% as.matrix())
