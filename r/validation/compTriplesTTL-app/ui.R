#______________________________________________________________________________
# FILE: r/validation/compTriplesTTL-appp/ui.R
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
#______________________________________________________________________________

fluidPage(
  titlePanel("Compare Data in Two Instance TTL files"),
  fluidRow (
      column(4, fileInput('fileOne', 'File 1'), style = "color:#000099"),
      column(4, fileInput('fileTwo', 'File 2'), style = "color:#00802b"),
      column(3, textInput('qnam', "Subject QName", value = "meddra:m10001316"))
  ),
  radioButtons("comp", "Compare:",
                c("In File 1, not in File 2" = "in1Not2",
                  "In File 2, not in File 1" = "in2Not1")),    
  h4("Unmatched Triples:",
    style= "color:#e60000"),
  tableOutput('unmatched'), 
  hr(),    
  fluidRow (
    column(6, 
      h4("File 1 Triples",
        style = "color:#000099"),
      tableOutput('file1SP')),
    column(6, 
      h4("File 2 Triples",
        style = "color:#00802b"),
      tableOutput('file2SP'))
  )  
)    