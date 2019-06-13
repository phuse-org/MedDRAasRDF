#______________________________________________________________________________
# FILE: r/validation/compTriplesTTL-appp/server.R
# DESC: Compare triples in two TTL files, starting at a named Subject.
#       COmmonly used to compare files generated separately by R, SAS, or 
#       ontology instance data.
# SRC :
# IN  : TTL files in a local folder. Typically /data/rdf
# OUT : 
# REQ : 
# SRC : 
# NOTE: Currently used for MedDRA construction with default subject set in 
#       ui.R
# TODO: 
#     
#
#______________________________________________________________________________

function(input, output, session) {

  # Ontology triples
  file1Triples <- reactive({
    req(input$fileOne)

    infileOne <- input$fileOne
    
    file.rename(infileOne$datapath,
                paste(infileOne$datapath, ".ttl", sep=""))
    
    queryString = paste0(prefixes,"
         SELECT ?s ?p ?o
         WHERE {", input$qnam, " ?p ?o . 
         BIND(\"", input$qnam, "\" as ?s) } ")
    
    rdf <- rdf_parse(paste(infileOne$datapath,".ttl",sep=""), format = "turtle")
    triplesFile1 <- rdf_query(rdf, queryString)

    # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
    triplesFile1 <- triplesFile1[!(triplesFile1$o==""),]
    triplesFile1 <- triplesFile1[complete.cases(triplesFile1), ]
    
    # Change URI to QNAM for display purposes
    triplesFile1 <- shortenIRI(sourceDF   = triplesFile1, 
                            colsToParse = c("p", "o") ,
                            usePrefix   = TRUE)
    triplesFile1 <- triplesFile1[with(triplesFile1, order(s,p,o)), ]
  })
  
  # Ontology triples table. Predicate and Objects only
  output$file1SP <-renderTable({
    triplesSPO <- file1Triples()
    triplesSPO <- triplesSPO[, c("p","o"), ]
  })    
  
  # R triples 
  file2Triples <- reactive({
    req(input$fileTwo)
    infileTwo <- input$fileTwo
        file.rename(infileTwo$datapath,
      paste(infileTwo$datapath, ".ttl", sep=""))

    queryString = paste0(prefixes,"
      SELECT ?s ?p ?o
      WHERE {", input$qnam, " ?p ?o . 
      BIND(\"", input$qnam, "\" as ?s) } ")

    rdf <- rdf_parse(paste(infileTwo$datapath,".ttl",sep=""), format = "turtle")
    triplesFile2 <- rdf_query(rdf, queryString)
    
    # Change URI to QNAM for display purposes
    triplesFile2 <- shortenIRI(sourceDF      = triplesFile2, 
                             colsToParse = c("p", "o") ,
                             usePrefix   = TRUE)
    
    triplesFile2 <- triplesFile2[with(triplesFile2, order(s,p,o)), ]
    
   }) 
    
  # R Triples Table. Predicate and Objects only
  output$file2SP <-renderTable({
    triplesSPO <- file2Triples()
    triplesSPO <- triplesSPO[, c("p","o"), ]
  })    
 
  #Triples that do not match between the two sources.
  output$unmatched <- renderTable({ 
    # Both input files are required for the comparison
    req(input$fileTwo, input$fileOne) 
    
    # Mismatch detection
    if (input$comp=='in1Not2') {
       compResult <<-anti_join(file2Triples(), file1Triples())
    }
    else if (input$comp=='in2Not1') {
       compResult <- anti_join(file1Triples(), file2Triples())
    }
    compResult
  })
}    