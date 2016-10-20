#!/usr/bin/Rscript

# Author : Bohdan Monastyrskyy
# Date   : 06/05/2012
# Description:
#   the script generates plots for domains analysis

# load required libraries
LIBS <- c("dplyr", "ggplot2", "tidyr", "RPostgreSQL")

sapply(LIBS, FUN = function(x){
  if (! require(x, character.only = TRUE)){
    install.packages(x, dependencies = TRUE);
    if (!require(x, character.only = TRUE)){
      stop(paste("The package", x, "has not been loaded."));
    } else {
      return(TRUE);
    }
  } else {
    return(TRUE);
  }
})

# load user-defined functions from file "functions.R"
source("Functions.R")

# set the mode variable
# 'FROMFILE' - for test purposes: the data will be read from file
# 'FROMDB' - the data will be fetched from database at predictioncenter.org
mode <- 'FROMFILE'
target <- 'T0759'
casp <- 'casp11'
index <- "D12"

# read data
if (mode == 'FROMDB'){
  source("config.R")
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, host=DB_HOST, user=DB_USER, dbname=DB_NAME)
  df <-  getData(mode=mode, casp=CASP, target=target, index=index, db_con = con)
  doms <- getDomainsFromDB(con, CASP)
} else if (mode == "FROMFILE"){
  df <-  getData(mode=mode, target=target, index = index)
  doms <- getDomainsFromFile(casp)
} else {
  stop("The value of the 'mode' variable has to be either 'FROMFILE' or 'FROMDB")
}

# reformat from long to wide format
df <- reformat(df)

# draw plot
plotXY(prepareXY(df,doms,target,index), target, index, toFile = TRUE)
