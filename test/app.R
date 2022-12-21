#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(leaflet)
library(shiny)
library(rsconnect)
library(urbnthemes)

# Define UI for application that draws a histogram
ui <- fluidPage(
    leafletOutput("mymap")
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$mymap <- renderLeaflet({
    leaflet(data = ch_bg) %>% 
      addTiles() %>%
      addPolygons(color = palette_urbn_cyan[4], 
                  weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE)) 
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
