library(tigris)
library(tidyverse)
library(urbnthemes)
library(sf)

set_urbn_defaults(style = "map")
options(tigris_class = "sf")

### import raw data
dc_bg_raw <- block_groups(
  state = "DC",
  cb = TRUE,
  year = 2021
) 

dc_tracts_raw <- tracts(
  state = 'DC',
  cb = TRUE,
  year = 2021
)

dc_state <- states(
  cb = TRUE,
  year = 2021
) %>%
  filter(STUSPS == 'DC') 

dc_wards <- st_read('Wards_from_1992/Wards_from_1992.shp') 

ch_landmarks <- read_csv('congress_heights_landmarks-geocoded.csv') 

# clean raw data
ch_bg <- dc_bg_raw %>%
  filter(TRACTCE == '007304' & BLKGRPCE %in% c('1','2','3') | TRACTCE == '009804' & BLKGRPCE %in% c('1','2')) %>%
  st_transform(crs = 'WGS84')

ch_tracts <- dc_tracts_raw %>%
  filter(TRACTCE == '007304' | TRACTCE == '009804') 

ward8 <- dc_wards %>%
  filter(WARD == 8)

### save cleaned data
write_csv(ch_bg, 'data/clean/ch_bg.csv')
write_csv(ch_tracts, 'data/clean/ch_tracts.csv')
write_csv(ward8, 'data/clean/ward8.csv')

### proposed boundaries and civic institutions
landmarks_proposedarea <- leaflet(data = ch_bg) %>% 
  addTiles() %>%
  addPolygons(color = palette_urbn_cyan[4], 
              weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE)) %>%
  addMarkers(data = ch_landmarks,
                    lng = ~Longitude, lat = ~Latitude, 
                    label = ~Name) %>%
  addProviderTiles(providers$CartoDB.Positron) 

landmarks_proposedarea
