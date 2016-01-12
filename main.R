# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 12 January 2016

# Start with empty environment
rm(list=ls())

# Get required libraries
library(raster)
library(rgdal)
library(rasterVis)
#set input and output folder
ifolder <- "./data/"
ofolder <- "./output/"
dir.create(ifolder, showWarnings = FALSE)
dir.create(ofolder, showWarnings = FALSE)
# Read R Code from function in map R

# Download data -----------------------------------------------------------

NDVIURL <- "https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip"

dir.create("data", showWarnings = FALSE)

inputZip <- list.files(path='data', pattern= '^.*\\.zip$')
if (length(inputZip) == 0){ ##only download when not alrady downloaded (safes time to debug the whole script)
	download.file(url = NDVIURL, destfile = 'data/NDVI_data.zip', method = 'wget')
	
}

# Download municipality boundaries
nlCity <- raster::getData('GADM',country='NLD', level=2,path='./data')


nlCity@data <- nlCity@data[!is.na(nlCity$NAME_2),] ## remove rows with NA



unzip('data/NDVI_data.zip', exdir="./data")


NDVIlist <- list.files(path='data/',pattern = '+.grd$', full.names=TRUE)

NDVI_12 <- stack(NDVIlist)
NDVI_Jan  <- NDVI_12[['January']] 
NDVI_Aug <- NDVI_12[['August']]

nlCity_sinu <- spTransform(nlCity, CRS(proj4string(NDVI_12)))

calib <- extract(NDVI_Jan, nlCity_sinu, df=TRUE,fun=mean)


