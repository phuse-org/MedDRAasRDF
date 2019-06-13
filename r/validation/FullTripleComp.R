###############################################################################
# FILE: FullTripleComp.R
# DESC: Compare all triples in two versions of a TTL file. 
#       Eg Usage: Compare TTL file generated from R and SAS
# SRC : 
#       
# IN  : File 1 (R) data/rdf/MedDRA211-CDISCPILOT01-Subset-R.TTL
#       File 2 (SAS) data/rdf/meddra221-sas.ttl
# OUT : datatables showing triples from one file that are not in the other
# REQ : rrdf
# NOTE: 
#       
# TODO: 
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rdflib)  # new for testing 
library(DT)

setwd("C:/_github/MedDRAasRDF")

queryString = 'SELECT ?s ?p ?o 
   WHERE {?s ?p ?o .}
  ORDER BY ?s ?p ?o'

#-- File 1 Triples ------------------------------------------------------------
rdf <- rdf_parse('data/rdf/MedDRA211-CDISCPILOT01-Subset-R.TTL', format = "turtle")
triplesFile1 <- rdf_query(rdf, queryString)


#--- File 2 Triples -----------------------------------------------------------
rdf <- rdf_parse('data/rdf/meddra221-sas.ttl', format = "turtle")
triplesFile2 <- rdf_query(rdf, queryString)

#--- In File 1 and not in File 2
File1NotFile2 <-anti_join(triplesFile1, triplesFile2)

# In File 2 and not in File 1
File2NotFile1 <- anti_join(triplesFile2, triplesFile1)

#--- Results ------------------------------------------------------------------
datatable(File1NotFile2,
          caption = "In R and not in SAS")

datatable(File2NotFile1,
          caption = "In SAS and not in R")