# Overview

## Purpose
- To be able to query the OMIM API for specific search terms directly through R. 
- Sort through resulting mimNumbers to select only those that are linked to an OMIM phenotype.
- Extract the following Phenotype-Gene information:
    - Phenotype mimNumber
    - Gene Location
    - Phenotype Name
    - Phenotype Mapping Key
    - Gene Name
    - Gene mimNumber
    - Description (Text)
    - Clinical Features (Text)
    - Clinical Synopsis (Text)
- Create filters to allow a user to easily check the output for whether your initial search term is present within the Description, Clinical Features, Clinical Synopsis text fields. 

## Input
- A search term to be queried into the 'omim_search_results' function to produce the initial dataframe of mimNumbers.
- From there, simply apply the functions within the 'OMIM_QUERY_FUNCTION.R' script as explained in more detail within the 'OMIM_SEARCHES.R' script. 

## Expected Output
- A dataframe with 13 columns as shown below:

Phenotype_mimNumber | Location | Phenotype | Phenotype_mapping_key | Gene | Gene_mimNumber | Description | Clinical_Features | Clinical_Synopsis | Search_Term | Description_Filter | Clinical_Features_Filter | Clinical_Synopsis_Filter
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- 
100800 | 4p16.3 | Achondroplasia | 3 | FGFR3, ACH | 134934 | Achondroplasia is the most frequent form of short-li... | Whereas many conditions that cause short stature... | Autosomal dominant {SNOMEDCT:771269000,2636... | Lethal | FALSE | TRUE | FALSE   
107480 | 16q12.1 | Townes-Brocks branchiootorenal-like syndrome	| 3 | SALL1, HSAL1, TBS | 602218 | Townes-Brocks syndrome-1 (TBS1) is characterized... | {28:Townes and Brocks (1972)} observed a father a... | Autosomal dominant {SNOMEDCT:771269000,2636... | Lethal | FALSE | TRUE | FALSE  
107480 | 16q12.1 | Townes-Brocks syndrome 1	| 3 | SALL1, HSAL1, TBS	| 602218 | Townes-Brocks syndrome-1 (TBS1) is characterized... | {28:Townes and Brocks (1972)} observed a father a... | Autosomal dominant {SNOMEDCT:771269000,2636... | Lethal | FALSE | TRUE | FALSE  
108120 | 9p13.2-p13.1 | Arthrogryposis, distal, type 1A | 3 | TPM2, TMSB, AMCD1, DA1, DA2B4, NEM4 | 190990 | In general, the distal arthrogryposes are a group of... | &lt;Subhead&gt; Distal Arthrogryposis, Type 1A1 {4... | Autosomal dominant {SNOMEDCT:771269000,2636... | Lethal | TRUE | FALSE | FALSE  			
108120 | 9p13.2-p13.1 | Arthrogryposis, distal, type 2B4 | 3 | TPM2, TMSB, AMCD1, DA1, DA2B4, NEM4 | 190990 | In general, the distal arthrogryposes are a group of... | &lt;Subhead&gt; Distal Arthrogryposis, Type 1A1 {4... | Autosomal dominant {SNOMEDCT:771269000,2636... | Lethal | TRUE | FALSE | FALSE 	
	
The number of rows can vary depending on the number of phenotype mimNumbers present within the mimNumber list.

## How to run this code
```
Make sure to run the 'OMIM_QUERY_FUNCTION.R' before you run the 'OMIM_SEARCHES.R'
```

## Important Notes
- In order to query the OMIM API, you are required to have a key which you can be given by requesting it at https://www.omim.org/api. Once you have received a key from OMIM you will need to replace the parts of the 'omim_search_results' and 'OMIM_XML_DF' functions written as '#####API_KEY_HERE#####', with the API key you will have received in order for these particular functions to properly work.
- One of the two search examples ('died') I have included within the 'OMIM_SEARCHES.R' script has more associated mimNumbers than that base API cap limit (2500) entries. So this particular example will take 2 days to run (due to waiting time for the daily cap to reset). 

## Particular areas of interest for improvement
- The lapply approach to apply the OMIM_XML_DF function across a list of mimNumbers can take a while (1-2 hours) using regular lapply or batchtools. So I'd be interested in suggested alternatives to speed up this particular part.
- General tips on imrpoving this code. With this being my first proper piece of code I've made for repeated use with work, I'm certain there are probably several bad habits, terrible practices and overall strange thought process in this. So any advice to improve upon this would be much appreciated.
- Suggestions on how to make the present output better to fulfill it's intended purpose. For example, I know that there are several R packages for XML parsing out there but I used flatxml because I found it the easiest to work with. But easier doesn't necessarily mean better so if you have alternative ways of coming to the same output I'd be happy to hear about them.

Many thanks in advance for taking the time to review my code!

Arun
