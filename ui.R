
library(shiny)
library(leaflet)


# Define UI for application that draws a histogram

shinyUI(fluidPage(
  titlePanel("Team 5 Crime Event Analysis"),
  fluidRow(
    
    
    column(3, wellPanel(
      # This outputs the dynamic UI component
      uiOutput("resList")
    )),
    
    column(8,
           tags$p("Restaurant:"),
           verbatimTextOutput("latlong")
           ##tags$p("Dynamic input value:"),
           ##verbatimTextOutput("dynamic_value")
    ),
    leafletOutput("mymap", height = "600")
  )
))

