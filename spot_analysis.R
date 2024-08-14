
# Author: 	madur (madur@psb.vib-ugent.be)
# Modified:	2024-08-14
# Requires:	
# 	-	TrackMate generated .xml files containing spot data.
# Description:
# 	Reads, combines and analyzes the data produced by the macro.


# user-defined functions --------------------------------------------------
require(XML)
# read only essential spot information from xml file
read_spots_tm_xml <- function(file) {
  temp <- xmlParse(file)
  df <- data.frame(
    id = xpathSApply(temp, '//Spot',  xmlGetAttr, "ID"),
    x = as.numeric(xpathSApply(temp, '//Spot',  xmlGetAttr, "POSITION_X")),
    y = as.numeric(xpathSApply(temp, '//Spot',  xmlGetAttr, "POSITION_Y")),
    avg_intensity = as.numeric(xpathSApply(temp, '//Spot',  xmlGetAttr, "MEAN_INTENSITY_CH1"))
  )
  return(df)
}

# combine all spot data from different xml files
gather_spot_data <- function() {
  files <- list.files(getwd())
  files <- files[endsWith(files, '.xml')]
  i = 0
  for(file in files) {
    if(i == 0){
      df <- cbind(read_spots_tm_xml(file), file = file)
      i <- 1
    }
    else {
      df <- rbind(df, cbind(read_spots_tm_xml(file), file = file))
    }
  }
  return(df)
}


# extra libraries ---------------------------------------------------------
library(stringr)
library(dplyr)
library(ggplot2)


# analysis ----------------------------------------------------------------


# get and combine data
setwd("/group/pcd/pcd_codebase/vavrdova_2024/test/output/")
spots <- gather_spot_data()


# plot totals
ggplot(
      summarise(
          group_by(spots, file)
        , count = n())
    , aes(y = count)) +
  geom_boxplot() +
  ylab("Number of spots")

# check quality of spots
ggplot(spots, aes(x = file, y = avg_intensity)) +
  geom_jitter(width = 0.2, alpha = 0.6)