#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(navbarPage(
  
  title = "Team 5 Crime Event Analysis",
  tabPanel(
    textInput("text", label="",value = "", placeholder = "Enter Restaurant")
  ),
  tabPanel(
    textInput("text", label="",value = "Seattle, WA", placeholder = "Enter Location")
  ),
  tabPanel(
    submitButton("Search", icon = icon("search", lib = "glyphicon"))
  ),
  fluidRow(
    column(width = 6, offset = 3,
      ## Replace here with a list view - start here##     
      fluidRow(
        sliderInput("bins",
                    "Zoom in/out:",
                    min = 1,
                    max = 50,
                    value = 30, width="100%"),
        selectInput(inputId = "crime_category",
                    label = "Select Crime Category:",
                    choices = c("Alcohol Abuse", "Assault", "Auto Theft", "Burglary","Criminal Presence","Disorderly Conduct","Drugs","Homicide","Theft","Violent Assault"),
                    selected = "Assault")
      ),
      fluidRow(
        tags$img(src='seattle_map.png')
      )
      ## Replace here with a list view - End here##     
    )
  )
  
  
  
  ,fluid = TRUE, responsive = TRUE, theme = "bootstrap.css"))
