# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 12 January 2016

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

# Download data -----------------------------------------------------------

NDVIURL <- "https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip"


inputZip <- list.files(path=ifolder, pattern= '^.*\\.zip$')
if (length(inputZip) == 0){ ##only download when not alrady downloaded (safes time to debug the whole script)
	download.file(url = NDVIURL, destfile = 'data/NDVI_data.zip', method = 'wget')
	
}

# Download municipality boundaries
nlCity <- raster::getData('GADM',country='NLD', level=2,path=ifolder)


nlCity@data <- nlCity@data[!is.na(nlCity$NAME_2),] ## remove rows with NA



unzip('data/NDVI_data.zip', exdir=ifolder)


NDVIlist <- list.files(path=ifolder,pattern = '+.grd$', full.names=TRUE)


NDVI_12 <- stack(NDVIlist)
nlCity_sinu <- spTransform(nlCity, CRS(proj4string(NDVI_12)))
NDVI_12 <- mask(NDVI_12,nlCity_sinu)

NDVI_Jan  <- NDVI_12[['January']] 
NDVI_Aug <- NDVI_12[['August']]
NDVI_mean <- calc(NDVI_12,mean)



Jan <- NDVIextract(NDVI_Jan,nlCity_sinu)
Aug <- NDVIextract(NDVI_Aug,nlCity_sinu)
Mean <- NDVIextract(NDVI_mean,nlCity_sinu)
cities <- cbind(nlCity_sinu$NAME_2, Jan[2],Aug[2],Mean[2])



colnames(cities)[1]<- 'City'
colnames(cities)[4]<- 'mean'



maxJan <- cities[cities$January==max(cities$January),]
maxAug <- cities[cities$August==max(cities$August),]
maxMean <- cities[cities$August==max(cities$August),]

nlCity_sinu$Jan<-cities$Jan
nlCity_sinu$Aug<-cities$Aug
nlCity_sinu$mean<-cities$mean
spplot(nlCity_sinu, zcol = "Jan",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main='NDVI January per municipality')
spplot(nlCity_sinu, zcol = "Aug",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main='NDVI August per municipality')
spplot(nlCity_sinu, zcol = "mean",col.regions= colorRampPalette(c("red","yellow","green","darkgreen"))(255)
			 ,main='mean NDVI per municipality')



