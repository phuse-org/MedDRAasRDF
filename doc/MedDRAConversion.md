# MedDRA Ontology and Data Conversion


## Introduction

The Medical Dictionary for Regulatory Activitites is a Medical Terminology (Dictionary) and Thesaurus that is 
clinically vaidated and used primarily by the International Conference on Harmonisation (ICH) and its members. It is used to characterize
Adverse Events. The MSSO (Maintenance and Support Services Organization) publishes an updated version twice a year.


The PhUSE project "Going Translational with Linked Data (GoTWLD)" required medDRA terminology as RDF for the coding of adverse events. This lead to the development of R and SAS scripts that convert the original ASCII files to RDF as TTL. The scripts can be used by anyone who wants to convert their copy of MedDRA to Linked Data. 


## MedDRA Terminology Organization

_Much of the content below is extracted from Dr. A. Oliva's presentation to the GoTWLD team on 2019-03-18. A recording of the meeting is available to team memmbers on the the project's Teamwork site under "Files."_

Each AE term is organized into five levels, from the Low Level Term (LLT) which is often the common term documented by the subject or investigator. There may be many synonyms at the Low Level which are then mapped to the Preferred Term (PT). Mapping continue to the High Level Term (HLT), High Level Group Term (HLGT), and System Organ Class (SOC). The thousands of terms map up to 27 SOCs in the current version of MedDRA. 

<img src="images/Meddra-TermsOrg.png" width=700/>
                 

### Multi-axiality
A term may map to two or more terms at a higher level. In the example below, the PT *Application Site Erythema* maps to two HLT's: *Application and Instillation Site Reactions* and *Erythemas*. This in turn leads to two SOC's in the hierarchy: *General Disorder and Administration site Conditions* and *Skin and Subcutaneous Tissue Disorders* . One of the SOC's is considered the Primary SOC (in this case,  "*General Disorder...") and others are Secondary SOC's. It is common for a single PT to result in mutliple SOC's.

<img src="images/Meddra-MultiAxial.png" width=700/>

## MedDRA Terminology Distribution
MedDRA is licensed, so source files are not provided as a part of this PhUSE project. We obtained a Research/Non Commercial license from the MSSO in order to perform this work.
The R conversion scripts detailed below can be freely used by anyone to construct the RDF from  licensed copy of terminology files.

### Why RDF for MedDRA Terminology?

* Single File (no merging needed)
* Explicit relationships between terms
* Can include documentation and other metadata

The MSSO maintains no RDF ontology. A number of companies have converted MedDRA to RDF, each using their own process. 

The project will create the scripts needed to convert the terminology to RDF. A subset of that terminology, relevant to the AE's in the project, will be available on the Github site.  The team will share their findings back to the MSSO, who have expressed an interest in MedDRA as RDF.  This is a limited conversion that does not include Standard MedDRA Queries (SMQ's) and is confined to the English representation only.


## Ontology

<img src="images/Meddra-LinktoAE.png" width=500/>

The object `meddra:m10012727` is the link to the MedDRA terminology in RDF.


### Ontology Structure

Our project created a MedDRA 'mini-ontology' focussed on our use case. It leverages [SKOS](https://www.w3.org/2004/02/skos/) which is well estabilished ontology for terminology. SKOS has three major classes relevant to this effort: 
`skos:ConceptScheme`  - analogous to the name of the dictionary. The dictionary contains Collections.
`skos:Collection`    - logical groupings of concepts. MedDRA has five collections. Collections contain members which are the individual concepts.
`skos:Concept`  - members of a collection which are further divided into subclasses, from Preferrred Concept all the way up to System Organ Class Concept. 


<img src="images/Meddra-Skos.png" width=500/>

Predicates were defined to express the relationships within the hieararchy, as well as the additionl predicate `meddra:hasPrimaryPTSOC` to link the preferred term to the primary SOC.  


In the diagram below, yellow boxes represent instance data and the pink are classes.  `skos:ConceptScheme` has an instance for the MedDRA version, `meddra:Meddra211` for the version of MedDRA used in this project. `skos:Collection` has the subclass `meddra:Collection` under which there are the five instances for the terminology level (Lowel to SOC).  The `skos:hasMember` predicate links the collection to the individual concepts that make up each collection. The diagram shows only the first nine AE's in the project data. 

<img src="images/Meddra-Structure.png" width=800/>

It is versy common for a  concept to appear in multiple classes. For example, the LLT `'m10003041` is mapped to itself as a PT (the lower level term *is* the preferred term in this case). 

Under `skos:Concep` we defined `meddra:MeddraConcept` and then further divided the concepts into the five classes of LLTConcept to SOCConcept (pink boxes).  The instances (yellow) are related to the classes by the `rdf:type` predicate. The instance data is linked together using the predicates `hasPT`, '`hasHLT`, etc. With the exception of `hasPT`, these latter predicates are a subproperty of `skos:broader`.

Note the how the predicate `hasPrimaryPTSOC` links with a blue line from a Preferred Term (`PTConcept`) to the `SOCConcept` to identify the Primary SOC. `hasPrimaryPTSOC` has a 1:1 relationship with the `PTConcept` and so is an `owl:FunctionalProperty`.  `hasPT` is expressing the synonym relationship between LLTconcept and PTConcept. 

**TODO: Update the new relation updated after 18MAR for the predicate that replaces `skos:broader` between LLTConcept and PTConcept**

### Instance data
File sdtm-cdisc01.ttl contains instance data that links a subject `cdiscpilot01:Person_01-701-1015` to the adverse event `cdiscpilot01:AE1_AppSiteErythema`. 


## Ontology Conventions

The project uses human-interpretable names for the resources as a way to aid understanding of the ontology and data.
    cdiscpilot01:**Person_01-701-1015**
        study:afflictedBy cdiscpilot01:AE03_**Diarrhoea** .

## Linking to the Subject data
The following SPARQL query inputs the adverse event record from our study instance data. The line `?ae code:hasCode ?LLT1` identifies the low level term for that event. Each higher level term in the hierarchy is queried and extracted. Our SDTM ontology contains this query as a SPIN rule. 

<img src="images/Meddra-Query.png" width=200/>


# Data Conversion
Both SAS and R can be used to convert the ASCII files to RDF using the processes documented below.

## Source Files
MedDRA files supplied by the MSSO as ASCII files with the .asc file extension. The files are serialized to RDF in the Terse Triple Language (TTL) format.

Five files contain the medication conditions and codes (LLT, PT, HLT, HLGT, SOC). See the diagrams below for how the files are related.

1. *llt.asc*
   - Contains the LLT code in column 1 and the PT code in column 3. In many cases the LLT and PT codes are identical. The PT code is used to link to the PT file.

2. *pt.asc*  
  - Contains the *Primary SOC* code to which the PT term is mapped.

3.*hlt.asc*

4. *hlgt.asc*

5. *soc.asc*

Three files contain additional mappings and, as indicated by their names, faciliate the merging of the terminology fils. 
1. *hlt_pt.asc*

2. *hlgt_hlt*

3. *soc_hlgt.asc*

These files enable mapping of any LLT to its Primary SOC and optionally to Secondary SOC's.

<img src="images/MedDRA-AscFileLinks.png" width=800/>


<img src="images/MedDRA-LLTtoSOC.png" width=800/>


### Data Subset
Three patients (1015, 1023, 1028) were selected from the CDISCPILOT01 dataset.

The patients reported 9 Adverse Events, two of which are not unique. Patient 1023 had two reports of Erythema (LLT 10015150) and patients 1015 and 1028 both reported Application site itching (LLT 10003047). This results in a unique list of 7 LLT Adverse event terms. 

When mapping from LLT to PT, the PT terms 10015150 and 10003041 are also their own LLT term. Also, some LLT terms map to the same PT:

LLT           PT
10003058  --> 10003041
10003041  --> 10003041

LLT           PT
10015150  --> 10015150
10024781  --> 10015150

The result is the need to pull only 5 codes from the PT file to match the 7 unique codes recorded as LLT terms. 


Merging from PT to HLT is facilitated by the file *hlt_pt.asc*. The left column of this file is the hlt code and the right column in the pt code. One PT often matches to mutliple HLT codes. For the subsetting, this results in 5 unique HLT codes.


The file hlgt_hlt.asc provides the links from HLT to HLGT. The left column is the HLGT code and the right is the HLT. The original 7 unique LLT terms have now rolled up into 4 HLGT codes.


The final from HLGT to SOC is provided in soc_hlgt.asc. 
 


## R Script
The R library `rdflib` is used to serialize the data into RDF. This package is a wrapper around the `redland` package, providing a much cleaner implementation. 


<img src="images/MedDRA-ProgramFlow-medDRAReadAsc.png" width=600/>




## Validation 
1.Ontology vs. R Script Validation

* r/validation/**compTriplesTTL-app**
* Local TTL files.
* RShiny app that reads the MedDRA ontology instance data (/rdf/meddra.ttl) and compares it with the instance data from the R conversion (MedDRA-211-R.ttl) on a "by Subject" basis.

2. Collapsible tree visualization

* r/vis/**MedDRALTtoSOCVis-app**
* Stardog Server (localhost), MedDRA database with TTL loaded
* TODO: Create a version of the app that uses local TTL file



[Back to TOC](TableOfContents.md)
