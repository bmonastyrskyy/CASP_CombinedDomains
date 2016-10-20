The project performs analysis for protein domains.

The question the analysis is supposed to address is 
whether the protein molecule should be splitted into 
domains or it should be kept as a single unit.

The code is running in two modes: TEST and WORK.
The main diference between them lays in how the data
 are retrieved. 
In WORK mode the data are fetched from database at 
predictioncenter.org.
In TEST mode the data are read from files deliberately
cretated for this purpose.

Content:
domainsPlot.R
data.csv - file contains artificial data which are used 
in test mode
