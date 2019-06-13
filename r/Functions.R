###############################################################################
# FILE: Functions.R
# DESC: General functions called by other R Scripts.
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
###############################################################################

#' Shorten IRIs to use prefix+value or just the value
#' Shorten full IRIs to their prefixed values. 
#'
#' @param sourceDF     Dataframe to process 
#' @param colsToParse  List of column names to be parsed
#' @param usePrefix    replace IRI with prefix (TRUE) or just the value (FALSE)
#' 
#' @return DF with shortened values 
#' 
#' @examples
#' nodesAllData <- shortenIRI(sourceDF=nodesAllData, colsToParse=c("id"), usePrefix=TRUE)

shortenIRI <- function(sourceDF, colsToParse, usePrefix=TRUE)
{  
  
  # Use to build prefix list and to regex-out results to use prefixed value.
  # NOTE: IRI does NOT include <xxx> 
  prefixes <- read.table(header=T, text='
    prefix iri
    drt:      https://www.example.org/ucb/ToolsAndAutomation/drt#
    owl:      http://www.w3.org/2002/07/owl#
    meddra:   https://w3id.org/phuse/meddra#
    rdf:      http://www.w3.org/1999/02/22-rdf-syntax-ns#
    rdfs:     http://www.w3.org/2000/01/rdf-schema# 
    skos:     http://www.w3.org/2004/02/skos/core#
    time:     http://www.w3.org/2006/time#
    xsd:      http://www.w3.org/2001/XMLSchema# 
    ')
  
  # Each row in the dataframe
  for (i in 1:nrow(sourceDF))
  {
    # each column to process
    lapply(colsToParse, function(currCol){
      # Loop through each prefix value and test it against the current data value
      #  current value is: sourceDF[i, currCol]
      for (j in 1:nrow(prefixes))
      {
        # The IRI is present in the current field, proceed to replace it.
        if (grepl(prefixes[j,2], sourceDF[i,currCol] ))
        {  
          # prefixes[j,2]  : IRI to be searched and replaced
          # prefixes[j,1]  : Prefix value to use in place of IRI
          if(usePrefix){
            # Replace the URI/IRI with a prefix to form a qname
            parseStart <- gsub(prefixes[j,2], prefixes[j,1], sourceDF[i,currCol])
          }else{
            # Remove the URI/IRI and do not replace with a perfix. 
            #   Keep only the unprefixed value.
            parseStart <- gsub(prefixes[j,2], "", sourceDF[i,currCol])  
          }  
          # Clean up the remaining parts of the original IRI
          parseStart <- gsub("#", "", parseStart)
          parseEnd   <- gsub(">", "", parseStart)
          # Use this code to create a new column name, leaving the orig intact.
          # newCol <- paste0(currCol,"_pref")
          # sourceDF[i, newCol] <<- parseEnd
          sourceDF[i, currCol] <<- parseEnd
        }
      }
    })  # of of lapply over each col to be evaluated
  }
  sourceDF  # Return the modified dataframe
} # end of Function