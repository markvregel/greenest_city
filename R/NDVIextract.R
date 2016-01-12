NDVIextract <- function(NDVI, mypolygon){
	
	NDVI_df <- extract(NDVI, mypolygon, df=TRUE,fun=mean,na.rm=TRUE)
	
	return(NDVI_df)
	
	
	
	
}