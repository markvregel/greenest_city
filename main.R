# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 12 January 2016
# Greenest city: find the city with the highest NDVI

# Start with empty environment
rm(list=ls())

# Get required libraries
library(raster)
library(rgdal)
library(rasterVis)

# Read R Code from function in map R
source("R/NDVIextract.R")

#set input and output folder
ifolder <- "./data/"
ofolder <- "./output/"
dir.create(ifolder, showWarnings = FALSE)
dir.create(ofolder, showWarnings = FALSE)
# Read R Code from function in map R

# Download data -----------------------------------------------------------------

# Download NDVI data
NDVIURL <- "https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip"
inputZip <- list.files(path=ifolder, pattern= '^.*\\.zip$')
if (length(inputZip) == 0){ ##only download when not alrady downloaded
	download.file(url = NDVIURL, destfile = 'data/NDVI_data.zip', method = 'wget')
	
}

# Download municipality boundaries
nlCity <- raster::getData('GADM',country='NLD', level=2,path=ifolder)

# Data pre-processing -----------------------------------------------------------

unzip('data/NDVI_data.zip', exdir=ifolder)  # unzip NDVI data
NDVIlist <- list.files(path=ifolder,pattern = '+.grd$', full.names=TRUE) # list NDVI raster
NDVI_12 <- stack(NDVIlist) # NDVI rasters

nlCity@data <- nlCity@data[!is.na(nlCity$NAME_2),] # remove rows with NA
nlCity_sinu <- spTransform(nlCity, CRS(proj4string(NDVI_12))) # change projection municipality data

NDVI_12 <- mask(NDVI_12,nlCity_sinu)# mask the NDVI stack to municipality data

# Select and calculate NDVI January, August and the mean of the year
NDVI_Jan  <- NDVI_12[['January']] 
NDVI_Aug <- NDVI_12[['August']]
NDVI_mean <- calc(NDVI_12,mean)


# Calculate NDVI for the municipalitys and find greenest cities--------------------

Jan <- NDVIextract(NDVI_Jan,nlCity_sinu)
Aug <- NDVIextract(NDVI_Aug,nlCity_sinu)
Mean <- NDVIextract(NDVI_mean,nlCity_sinu)

# Combine result into one dataframe
cities <- cbind(nlCity_sinu$NAME_2, Jan[2],Aug[2],Mean[2])
colnames(cities)[1]<- 'City'
colnames(cities)[4]<- 'Mean'

# find the greenest cities

maxJan_spatial<- nlCity_sinu[cities$January==max(cities$January),]
maxAug_spatial<- nlCity_sinu[cities$August==max(cities$August),]
maxMean_spatial<- nlCity_sinu[cities$Mean==max(cities$Mean),]

# add NDVI data to spatial of the data municipalities
nlCity_sinu$Jan<-cities$Jan
nlCity_sinu$Aug<-cities$Aug
nlCity_sinu$Mean<-cities$Mean

# Visualization-----------------------------------------------------------------

spplot(nlCity_sinu, zcol = "Jan",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main=paste('NDVI January per municipality\n Greensest City:', maxJan_spatial$NAME_2),
			 sp.layout = list('sp.polygons', maxJan_spatial,col="red",first=F,lwd=3))
spplot(nlCity_sinu, zcol = "Aug",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main=paste('NDVI August per municipality\n Greensest City:', maxAug_spatial$NAME_2),
			 sp.layout = list('sp.polygons', maxAug_spatial,col="red",first=F,lwd=3))
spplot(nlCity_sinu, zcol = "Mean",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main=paste('Mean NDVI per municipality\n Greensest City:', maxMean_spatial$NAME_2),
			 sp.layout = list('sp.polygons', maxMean_spatial,col="red",first=F,lwd=3))


