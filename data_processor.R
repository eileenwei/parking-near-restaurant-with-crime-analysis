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

setwd("/Users/EILEENWEI/Team5")
block_seattle_datafile <- file.path("/Users/EILEENWEI/Team5/DataObjects","block_seattle.rds")




##########################################################################################################################
##################################        Crime Data       ############################################################### 
##########################################################################################################################

data <- read.csv('Seattle_Police_Department_Police_Report_Incident.csv')
## Eliminate data that does not contain coordinates
data <- data[!is.na(data$Longitude)&!is.na(data$Latitude),]
crimeData <- subset(data, Summarized.Offense.Description != "[INC - CASE DC USE ONLY]" & Summarized.Offense.Description != 
                      "ANIMAL COMPLAINT" & Summarized.Offense.Description != "BIAS INCIDENT" & Summarized.Offense.Description != "COUNTERFEIT"
                    & Summarized.Offense.Description != "DUI" & Summarized.Offense.Description != "ELUDING"
                    & Summarized.Offense.Description != "EMBEZZLE" & Summarized.Offense.Description != "ESCAPE"
                    & Summarized.Offense.Description != "FALSE REPORT" & Summarized.Offense.Description != "FIREWORK"
                    & Summarized.Offense.Description != "GAMBLE" & Summarized.Offense.Description != "HARBOR CALLS"
                    & Summarized.Offense.Description != "ILLEGAL DUMPING" & Summarized.Offense.Description != "INJURY"
                    & Summarized.Offense.Description != "LOST PROPERTY" & Summarized.Offense.Description != "METRO"
                    & Summarized.Offense.Description != "OBSTRUCT" & Summarized.Offense.Description != "OTHER PROPERTY"
                    & Summarized.Offense.Description != "PORNOGRAPHY" & Summarized.Offense.Description != "PROSTITUTION"
                    & Summarized.Offense.Description != "RECOVERED PROPERTY" & Summarized.Offense.Description != "STAY OUT OF AREA OF PROSTITUTION"
                    & Summarized.Offense.Description != "TRAFFIC" )

## Get the more precise coordinates using Location
library(splitstackshape)
crimeData$Location1 <- as.character.factor(crimeData$Location)
crimeData <- cSplit(crimeData, "Location1", ",", drop = FALSE)

options(digits=12)
crimeData$Location1_1  <- as.numeric(gsub("\\(|\\)", "", crimeData$Location1_1))
crimeData$Location1_2  <- as.numeric(gsub("\\(|\\)", "", crimeData$Location1_2))


coordinates(crimeData)=~Location1_2+Location1_1




##########################################################################################################################
##################################        Block Data       ############################################################### 
##########################################################################################################################

# Read in the shapefile that describes the census tract boundaries.
# block <- readOGR(dsn = "WABlockData", layer = "tl_2012_53_tabblock")
block <- shapefile("WABlockData/tl_2012_53_tabblock.shp")

# Clear data
block <- block[!is.na(block$INTPTLAT)&!is.na(block$INTPTLON),] 

# Get blocks that are within Seattle
block_seattle <- subset(block, ((as.numeric(as.character(block$INTPTLAT)) < 47.734145 & as.numeric(as.character(block$INTPTLAT)) > 47.48172) & (as.numeric(as.character(block$INTPTLON)) < -122.224433 & as.numeric(as.character(block$INTPTLON)) > -122.459696)))

# block_seattle$GEOID <- as.character.factor(block_seattle$GEOID)


### Overlaying with crime data
projection(crimeData)=projection(block_seattle)
crime_block <- over(crimeData,block_seattle)

crimeData@data <- data.frame(crimeData@data, crime_block)

crimeData@data$count <- 1
# Aggregate the crime data
agg_crime_block <- aggregate(formula=count~GEOID, data=crimeData@data, FUN=length)
# agg_crime_block$GEOID <- as.character.factor(agg_crime_block$GEOID)

m <- match(x= block_seattle$GEOID, table=agg_crime_block$GEOID)
block_seattle@data$count <- agg_crime_block$count[m]

block_seattle@data$count[is.na(block_seattle@data$count)] <- 0


#grab a palette
library(RColorBrewer)

pal <- brewer.pal(11, "Spectral")




#now make it more continuous 
#as a colorRamp
pal <- colorRampPalette(pal)

# now, map it to  values
library(classInt)
palData <- classIntervals(block_seattle@data$count, style="quantile")

#note, we use pal(100) for a smooth palette here
#but you can play with this
block_seattle@data$colors <- findColours(palData, pal(100))

colfunc <- colorRampPalette(c("green","red"))
color_list <- colfunc(633)
block_seattle@data$colors <- color_list[block_seattle@data$count]


saveRDS(block_seattle, file = block_seattle_datafile)

