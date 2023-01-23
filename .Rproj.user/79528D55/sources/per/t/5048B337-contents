library(leaflet)

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
