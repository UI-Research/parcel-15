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
  filter(STUSPS == 'DC') %>%
  st_transform("EPSG:6487")

dc_wards <- st_read('Wards_from_1992/Wards_from_1992.shp') %>%
  st_transform("EPSG:6487") 

ch_landmarks <- read_csv('congress_heights_landmarks-geocoded.csv') %>%
  st_transform("EPSG:6487")

# clean raw data
dc_bg <- dc_bg_raw %>%
  filter(TRACTCE == '007304' & BLKGRPCE %in% c('1','2','3') | TRACTCE == '009804' & BLKGRPCE %in% c('1','2')) %>%
  st_transform("EPSG:6487")

ch_tracts <- dc_tracts_raw %>%
  filter(TRACTCE == '007304' | TRACTCE == '009804') %>%
  st_transform("EPSG:6487")

dc_roads <- roads(
  state = "DC",
  county = "District of Columbia",
  class = "sf",
  progress_bar = FALSE
) %>%
  st_transform("EPSG:6487")

ward8 <- dc_wards %>%
  filter(WARD == 8)

### intersect cleaned data to zoom in
congress_heights <- st_intersection(dc_bg, dc_tracts)
ward8_roads <- st_intersection(ward8,dc_roads)

### map congress heights neighborhood
ggplot() +
  geom_sf(data = ward8,
          mapping = aes(),
          fill = 'white',
          color = palette_urbn_cyan[5]) +
  geom_sf(data = congress_heights,
          mapping = aes(),
          fill = palette_urbn_cyan[2])  +
  geom_sf(data = ward8_roads,
          mapping = aes(),
          color = palette_urbn_gray[7]) +
  geom_sf(data = ch_landmarks,
          mapping = aes())

ggplot() +
  geom_sf(data = dc_tracts,
          mapping = aes()) +
  geom_sf(data = dc_bg,
          mapping = aes()) +
  theme_urbn_map()
