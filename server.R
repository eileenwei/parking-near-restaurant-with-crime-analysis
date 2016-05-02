library(shiny)
library(leaflet)

shinyServer(function(input, output) {
  
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
    iconUrl = "carpark.png",
    iconWidth = 28, iconHeight = 38)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
    setView(lng = long(), lat = lat() , zoom = 15) %>%
    addMarkers(data=parkingdata(), icon=carpark, popup=paste("<b>Parking Name: </b>",parkingdata()$Name,"<br>",
                                             "<b>Address: </b>",parkingdata()$Address,"<br>",
                                             "<b>Hours M-F: </b>",parkingdata()$HoursMF,"<br>",
                                             "<b>Hours S: </b>",parkingdata()$HoursWknd,"<br>",
                                             "<b>Price: </b>",parkingdata()$Price,"<br>",
                                             "<b>Distance: </b>",round(parkingdata()$Distance, digits=2),"<br>"))%>%
    addMarkers(data=res(), popup = paste("<b>Restaurant Name: </b>",res()$Name,"<br>",
                                         "<b>Address: </b>",res()$Address,"<br>"))
  
  })
  
})