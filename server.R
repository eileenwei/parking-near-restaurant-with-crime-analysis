#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

## renderLeaflet() is used at server side to render the leaflet map 

shinyServer(function(input, output) {
  output$mymap <- renderLeaflet({
    # define the leaflet map object
    leaflet() %>%
      addTiles() %>%
      setView(lng = -122.3321, lat = 47.6062 , zoom = 15) %>%
      addMarkers(lng = -122.3321, lat = 47.6062, popup = "Seattle")
  })
  
})
