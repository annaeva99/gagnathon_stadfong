pacman::p_load(arrow, dplyr, tidyr, here, data.table, tidyverse)

hnit_rvk <- fread(here("data", "stofnanir_rvk_hnit.csv")) %>% as_tibble()
hnit_rvk <- hnit_rvk %>% rename(long = E_HNIT_WGS84, lat = N_HNIT_WGS84)
opnirreikningar <- read_parquet(here("data", "opnirreikningar.parquet"), )

# sameina hnit og stonun í opnirreikningar

opnirreikningar_rvk <- opnirreikningar %>% filter(kaupandi %in% hnit_rvk$Stofnun)
opnirreikningar_rvk <- opnirreikningar_rvk %>% left_join(hnit_rvk %>% select(kaupandi = Stofnun, long, lat, hnit_num = HNITNUM), by = "kaupandi")

write_parquet(opnirreikningar_rvk, "data/opnirreikningar_rvk_hnit.parquet")
