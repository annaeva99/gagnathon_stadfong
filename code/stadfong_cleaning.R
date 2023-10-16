pacman::p_load(pdftables, readxl, data.table, tidyr, tidyverse)

# Lesum inn staðfangaskrár og félgasskrá
ffr_felagsskra <- readxl::read_xlsx("data-raw/ffr_felagsskra_4mai.xlsx")
stadfangaskra <- fread("data-raw/stadfangaskra_extra.csv")
stjornsysluhverfi <- fread("data-raw/stjornsysluhverfi.csv")

# Lagfæringar á skráningu heimilisfanga í RVK
ffr_reykjavik <- ffr_felagsskra %>% filter(Staður == "Reykjavík") %>% 
                                    mutate(heimilisfang_stonunar = case_when(
                                      str_detect(`Heimilisfang stofnunar`, "Staðastað, Sóleyjargötu 1") ~ "Sóleyjargötu 1", 
                                      str_detect(`Heimilisfang stofnunar`, "Kringlan 1. 5. hæð") ~ "Kringlunni 1",
                                      str_detect(`Heimilisfang stofnunar`, "Suðurlandsbraut 4, 2.hæð") ~ "Suðurlandsbraut 4",
                                      str_detect(`Heimilisfang stofnunar`, "Orkugarði, Grensásvegi 9") ~ "Grensásvegi 9",
                                      str_detect(`Heimilisfang stofnunar`, "Borgarleikhúsinu, Listabraut 3") ~ "Listabraut 3",
                                      str_detect(`Heimilisfang stofnunar`, "Árnagarði v/Suðurgötu") ~ "Sturlugötu 1",
                                      str_detect(`Heimilisfang stofnunar`, "Borgartúni 5-7") ~ "Borgartúni 5",
                                      str_detect(`Heimilisfang stofnunar`, "Bústaðavegi 7-9") ~ "Bústaðavegi 7",
                                      str_detect(`Heimilisfang stofnunar`, "við Mosaveg") ~ "Mosavegi 15",
                                      TRUE ~ `Heimilisfang stofnunar`
                                      ))


ffr_reykjavik <- ffr_reykjavik %>% separate(heimilisfang_stonunar, into = c("HEITI_TGF", "HUSNR"), sep = " ", remove = F) %>% mutate(HUSMERKING = toupper(HUSNR))


tmp <- ffr_reykjavik  %>% left_join(stadfangaskra, by = c("HEITI_TGF", "HUSMERKING")) %>% drop_na(HNITNUM)
tmp <- tmp %>% select(Stofnun, Ráðuneyti, heimilisfang_stonunar, N_HNIT_WGS84, E_HNIT_WGS84, HNITNUM)

write.table(tmp, "data/stofnanir_rvk_hnit.csv", row.names = F)
