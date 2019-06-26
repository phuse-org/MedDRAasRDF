###############################################################################
# FILE: TestQuery-RemoteEP.R
# DESC: Test query to remote endpoint from R 
# IN  : http://34.216.170.22:5820/MedDRA211/query
# OUT : R dataframe
# REQ : Data uploaded to the MedDRA211 graph on remote server
# NOTE:
# TODO: 
###############################################################################
library(SPARQL)

# Query Remote MedDRA endpoint ----
endpoint <- "http://34.216.170.22:5820/MedDRA211/query"

query <- "SELECT ?s ?p ?o
WHERE
{
  ?s ?p ?o
}LIMIT 10"

# Or: ready prefixes in from prefixes.csv project file.
prefix <- c("bibo",         "http://purl.org/ontology/bibo/",
            "cdiscpilot01", "https://w3id.org/phuse/cdiscpilot01#",
            "dcterms",      "http://purl.org/dc/terms/",
            "meddra",       "https://w3id.org/phuse/meddra#", 
            "pav",          "http://purl.org/pav",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "skos",         "http://www.w3.org/2004/02/skos/core#")

qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
resultsDF