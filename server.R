
#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
# Author: Eileen Wei
# Email: haochiw@andrew.cmu.edu

##########################################################################################################################
##################################        Set-up       ################################################################### 
##########################################################################################################################
library(sp)
library(rgdal)
library(gpclib)
library(ggmap)
library(ggplot2)
#library(spatstat)
#library(PBSmapping)
library(maptools)
library(Cairo)
library(scales)
library(spatstat)
library(raster)    
# give maptools the permission to use gpclib
gpclibPermit()
library(splitstackshape)

library(shiny)
library(leaflet)

#grab a palette
library(RColorBrewer)

# Objects in this file are shared across all sessions
#source('data_processor.R', local=TRUE)
# blocks_seattle <- readRDS("/Users/EILEENWEI/Team5/DataObjects","block_seattle.rds")
blocks_seattle <- block_seattle




shinyServer(function(input, output) {
  
  pal <- colorNumeric(
    palette = colorRampPalette(c("green","red")),
    domain = blocks_seattle@data$count)
  
  ## Map
  popup<-paste(sep = "<br/>",
               paste0("<b>Seattle Crime</b>"),
               paste0("<b>Block:</b> ",blocks_seattle@data$GEOID),
               paste0("<b>Criminal Incidents:</b> ",blocks_seattle@data$count)
  )
  
  factpal <- colorFactor(topo.colors(5), blocks_seattle@data$count)
  
  restaurant <- read.csv("Data/RestaurantData.csv", header = TRUE)
  parking <- read.csv("Data/Parking.csv", header = TRUE)
  parkingtemp<-parking
  
  output$resList <- renderUI({
           "radioButtons" =  radioButtons("dynamic", "Search Result", 
                                          choices = c("Bar & Grill"="11", "Appricot Takeover" = "13"), 
                                          selected="11")
  })
  
  
  earth<- function (long1, lat1, long2, lat2)
  {
    rad <- pi/180
    a1 <- lat1 * rad
    a2 <- long1 * rad
    b1 <- lat2 * rad
    b2 <- long2 * rad
    dlon <- b2 - a2
    dlat <- b1 - a1
    a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
    c <- 2 * atan2(sqrt(a), sqrt(1 - a))
    R <- 6378.145
    d <- R * c
    return(d)
  }
  
  calcParking <- function(n){
    parkingtemp$Distance<-as.numeric(earth(long(), lat(), parking$Longitude, parking$Latitude))
    print(parkingtemp)
    parkingtemp <- parkingtemp[which(parkingtemp$Distance<=1), ]
    print(parkingtemp)
    return(parkingtemp)
  }
  
  
  lat <- reactive({as.numeric(restaurant[grep(input$dynamic, restaurant$ID),4])})
  long <- reactive({as.numeric(restaurant[grep(input$dynamic, restaurant$ID),5])})
  res <- reactive({(restaurant[grep(input$dynamic, restaurant$ID),2:5])}) 
  parkingdata<-reactive({calcParking(input$dynamic)}) 
  
 
   output$latlong <- renderText({
    paste("Name:", res()$Name, "Address:", res()$Address)
  })
  
  ##output$dynamic_value <- renderPrint({
    ##str(input$dynamic)
  ##})
  
  carpark <- makeIcon(
    iconUrl = "parking.png",
    iconWidth = 28, iconHeight = 38)
  
  yelpmark <- makeIcon(
    iconUrl = "yelp-icon.png",
    iconWidth = 38, iconHeight = 38)
  
  output$mymap <- renderLeaflet({
    leaflet(blocks_seattle,height = 600) %>%
      setView(lng = long(), lat = lat() , zoom = 11) %>%
      addTiles() %>%
      addPolygons(weight=2,fillOpacity = 0.6, smoothFactor = 0.5,color=NA,
                  fillColor = ~colors,popup=popup) %>%
    #     addLegend(pal = pal, 
    #                values = blocks_seattle@data$count, 
    #                position = "topright", 
    #                title = "Seattle 2014-2016 Crime Rates",
    #                labFormat = labelFormat(suffix = ""))  
    addMarkers(data=parkingdata(), icon=carpark, popup=paste("<b>Parking Name: </b>",parkingdata()$Name,"<br>",
                                             "<b>Address: </b>",parkingdata()$Address,"<br>",
                                             "<b>Hours M-F: </b>",parkingdata()$HoursMF,"<br>",
                                             "<b>Hours S: </b>",parkingdata()$HoursWknd,"<br>",
                                             "<b>Price: </b>",parkingdata()$Price,"<br>",
                                             "<b>Distance: </b>",round(parkingdata()$Distance, digits=2),"<br>"))%>%
    addMarkers(data=res(), icon=yelpmark, popup = paste("<b>Restaurant Name: </b>",res()$Name,"<br>",
                                         "<b>Address: </b>",res()$Address,"<br>"))
  

  
})
  
})

