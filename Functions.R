#!/usr/bin/Rscript

# Author : Bohdan Monastyrskyy
# Date : 06/05/2012
# Description:
#   The file contains functions used in domainsPlot.R script

# require : dplyr, tidyr, RPostgreSQL

# generic function to retrieve data
getData <- function(mode='FROMDB', casp='casp11', target='T0759', index = 12, db_con = NA){
  if (mode == 'FROMDB'){
    return(getDataFromDB(db_con, casp, target, index));
  } else if (mode == 'FROMFILE'){
    return(getDataFromFile(target, index));
  }
}

# the index is assumed to be two-digit number
getDataFromDB <- function(con,casp,target,index){
  index1 <- substring(index, 2, 2)
  index2 <- substring(index, 3, 3)
  index12 <- substring(index, 2, 3)
  query <- paste0("
  SELECT t.name, 'D'||re.domain,  gr.code, pr.model, gdt_ts_4 as gdt_ts ",
    " FROM ", casp, ".results re", 
    " JOIN ", casp, ".predictions pr ON re.predictions_id=pr.id ",
    " JOIN ", casp, ".groups gr ON pr.groups_id = gr.id ",
    " JOIN ", casp, ".targets t ON pr.target::text = t.name ",
    " JOIN ", casp, ".domains d ON d.targets_id = t.id ",
  " WHERE re.domain IN (",index1,",",index2,",",index12,") AND gr.type IN (1,2) AND t.name SIMILAR TO 'T0%'
    AND re.domain = d.index and 
  ORDER BY (t.name, re.domain, gr.code, pr.model)");
  res <- dbSendQuery(con, query)
  res <- as.data.frame(fetch(res, n = -1))
  res
}


# get data from file
getDataFromFile <- function(target,index){
  file <- paste0("data/", target, "-",index, ".csv")
  res <- read.table(file, stringsAsFactors = FALSE, header=TRUE, comment.char = '%', sep = ',')
  res
}

# get domains from database
getDomainsFromDB <- function(con,casp){
  query <- paste("SELECT t.name as target, d.index as domain, d.length, dc.name as dom_class ",
  " FROM ", casp, ".domains d ",
  " JOIN ", casp, ".targets t ON t.id = d.targets_id ",
  " LEFT JOIN ", casp, ".domain_classifications dc ON dc.id=d.domain_classifications_id ",
  " WHERE t.name SIMILAR TO 'T0%' AND d.index NOT IN (7,8,9) ",
  " ORDER BY (t.name, d.index)");
  res <- dbSendQuery(con, query);
  res <- as.data.frame(fetch(res, n = -1));
  res
}

# get domains from 
getDomainsFromFile <- function(casp){
  file <- paste0("data/", casp, ".domains.csv")
  res <- read.table(file, stringsAsFactors = FALSE, header = TRUE, sep = ',', comment.char = '%')
  res
}

# generate score for missing model
# the score is generated according to
# the formula : 102.8*exp( -0.089 * (dom_length**0.729)) + 11.3
genScoreForMissingModel <- function(dom_length){
  if (!missing(dom_length)){
    return (102.8*exp( -0.089 * (dom_length**0.729)) + 11.3);
  }
}

# reformat data.frame
reformat <- function(df){
  # long to wide format
  spread_(df[, which(colnames(df) != 'length')], "domain", "gdt_ts")
}

# prepare data for plot
prepareXY <- function(df, doms, .target = 'T0759', index = 'D12'){
  index1 <- paste0('D', substring(index, 2, 2))
  index2 <- paste0('D', substring(index, 3, 3))
  index12 <- paste0('D', substring(index, 2, 3))
  w1 <- (filter(doms, target == .target & domain == index1) %>% select(length))[[1,1]]
  w2 <- (filter(doms, target == .target & domain == index2) %>% select(length))[[1,1]]
  w12 <- (filter(doms, target == .target & domain == index12) %>% select(length))[[1,1]]
  tmp <- df[complete.cases(df),]
  tmp$comb <- mapply(FUN = function(x,y){(x*w1 + y*w2)/w12}, tmp[,index1], tmp[,index2])
  res <- data.frame( x = select_(tmp,index12), y = tmp$comb)
  colnames(res) <- c('x','y')
  res
}

# plot
plotXY <- function(xy, target = 'T0759', index = 'D12', toFile = FALSE){
  if (toFile){
     png(paste0("plots/", target, '-', index, '.png'), width=480, height=480, bg="white",units="px",  pointsize=12);
  }
  plot(xy$x, xy$y, pch=20, xlim=c(0,100), ylim=c(0,100), 
     main=paste0(target,'-', index), 
     xlab='GDT_TS of combined domain', 
     ylab='separated domains: weighted sum of GDT_TS');
  par(mar=c(6,4,4,2))
  mtext("", side=1, line=3, cex=1, outer=FALSE)
  mtext("", side=1, line=4, cex=1, outer=FALSE)
  mtext("", side=1, line=5, cex=1, outer=FALSE)
  abline(v=(seq(0,100,5)), col="lightgray", lty="dotted")
  abline(h=(seq(0,100,5)), col="lightgray", lty="dotted")
  lines(c(-5,105),c(-5,105), col='red')
  fit <- lm(xy$y ~ 0 + xy$x)
  abline(fit, col="green")
  if (toFile){
    dev.off();
  }
}
