library(flatxml)
library(plyr)
library(dplyr)
library(stringr)
library(tidyr)
library(data.table)

#####FUNCTION TO OBTAIN A LIST OF MATCHED MIM NUMBERS WITH A SEARCH TERM#####
# For 'AND' 'OR' operator searches add '%20' where there would be spaces e.g.
# 'perinatal AND lethal' == 'perinatal%20AND%20lethal'
# For multi-worded searches add '_' where there would be spaces e.g.
# 'life threatening' == 'life_threatening'
omim_search_results <- function(search_term){
  
  url_1 <- 'https://api.omim.org/api/entry/search?search='
  url_2 <- '&format=xml&start=0&limit=15000&apiKey=#####API_KEY_HERE#####'
  url <- paste(url_1, search_term,url_2)
  url <- gsub(" ", "", url)
  df <- fxml_importXMLFlat(url)
  search_term_mimNumbers <- df %>% filter(elem. == 'mimNumber')
  search_term_mimNumbers <- search_term_mimNumbers %>%   select(value.)
  search_term_mimNumbers <- rename(search_term_mimNumbers, c('mimNumber' = 'value.'))
  return(search_term_mimNumbers)
}

#####FUNCTION TO OBTAIN A DATAFRAME CONTAINING THE RAW XML OF A GIVEN MIM NUMBER##### 
OMIM_XML_DF <- function(mimNumber){
  
  url1 <- 'https://api.omim.org/api/entry?mimNumber='
  url2 <- '&include=all&apiKey=#####API_KEY_HERE#####'
  url <- paste(url1, mimNumber ,url2)
  url <- gsub(" ", "", url)
  df <- fxml_importXMLFlat(url)
  return(df)
}
#####FUNCTION TO SUBSET ROWS AROUND A SELECTED ROW##### #This is used to extract the 'Description' and 'Clinical Features' text from the XML df.
extract.with.context <- function(x, rows, after = 0, before = 0) {
  
  match.idx  <- which(rownames(x) %in% rows)
  span       <- seq(from = -before, to = after)
  extend.idx <- c(outer(match.idx, span, `+`))
  extend.idx <- Filter(function(i) i > 0 & i <= nrow(x), extend.idx)
  extend.idx <- sort(unique(extend.idx))
  
  return(x[extend.idx, , drop = FALSE])
}
#####FUNCTION TO OBTAIN CLINICAL FEATURES TEXT FROM AN XML DATAFRAME#####
ClinicalFeaturesText <- function(df){
  
  ClinFeatRow <- df %>% filter(grepl('Clinical Features', value.))
  ClinFeatRowNo <- which(grepl('Clinical Features', df$value.))
  if (empty(ClinFeatRow) != TRUE){
    ClinFeatRows <- extract.with.context(df, ClinFeatRowNo, after = 1, before = 1)
    ClinicalFeatRow <- tail(ClinFeatRows, n=1)
    ClinFeatTxt <- as.character(ClinicalFeatRow$value.)
  } else {
    ClinFeatTxt <- 'N/A'
  }
  return(ClinFeatTxt)
}

#####FUNCTION TO OBTAIN CLINICAL SYNOPSIS TEXT FROM AN XML DATAFRAME#####
ClinicalSynopsisText <- function(df){
  
  oldFormatRows <- df %>% filter(level5 == 'oldFormat')
  ClinSynRows <- df %>% filter(level4 == 'clinicalSynopsis')
  if (empty(oldFormatRows) != TRUE){
    oldFormat <- oldFormatRows %>% drop_na(level6)
    ClinicalSynopsis <- as.character(oldFormat$value.)
  } else {
    if (empty(ClinSynRows) != TRUE){
      ClinSynRows <- ClinSynRows %>% drop_na(value.)
      ClinSyn <- ClinSynRows %>% filter(!grepl('Exists', level5))
      ClinSyn <- ClinSyn %>% filter(!grepl('Date', level5))
      ClinSyn <- ClinSyn %>% filter(!grepl('History', level5))
      ClinSyn <- ClinSyn %>% filter(!grepl('Created', level5))
      ClinSyn <- ClinSyn %>% filter(!grepl('Updated', level5))
      ClinicalSynopsis <- as.character(ClinSyn$value.)
    } else {
      ClinicalSynopsis <- 'N/A'
    }
  }
  return(ClinicalSynopsis)
}

#####FUNCTION TO OBTAIN DESCRIPTION TEXT FROM AN XML DATAFRAME#####
DescriptionText <- function(df){
  
  DescriptionRow <- df %>% filter(grepl('Description', value.))
  DescriptionRowNo <- which(grepl('Description', df$value.))
  if (empty(DescriptionRow) != TRUE){
    DescriptionRows <- extract.with.context(df, DescriptionRowNo, after = 1, before = 1)
    DescriptionRow <- tail(DescriptionRows, n=1)
    DescriptionTxt <- as.character(DescriptionRow$value.)
  } else {
    DescriptionTxt <- 'N/A'
  }
  return(DescriptionTxt)
}

#####FUNCTION TO MAKE GENE PHENOTYPE MAP FROM AN XML DF#####
Gene_Phenotype_Map <- function(df){
  
  Phenotype_Map <- df %>% filter(level4 == 'phenotypeMapList')
  Phenotype_Map <- Phenotype_Map %>%   select(elem., value.)
  Locations <- Phenotype_Map %>% filter(elem. == 'cytoLocation')
  Locations <- rename(Locations, c('Location' = 'value.'))
  Locations <- select(Locations, -1)
  Phenotypes <- Phenotype_Map %>% filter(elem. == 'phenotype')
  Phenotypes <- rename(Phenotypes, c('Phenotype' = 'value.'))
  Phenotypes <- select(Phenotypes, -1)
  Phenotype_mimNumbers <- Phenotype_Map %>% filter(elem. == 'phenotypeMimNumber')
  Phenotype_mimNumbers <- rename(Phenotype_mimNumbers, c('Phenotype_mimNumber' = 'value.'))
  Phenotype_mimNumbers <- select(Phenotype_mimNumbers, -1)
  Phenotype_mapping_keys <- Phenotype_Map %>% filter(elem. == 'phenotypeMappingKey')
  Phenotype_mapping_keys <- rename(Phenotype_mapping_keys, c('Phenotype_mapping_key' = 'value.'))
  Phenotype_mapping_keys <- select(Phenotype_mapping_keys, -1)
  Gene_Names <- Phenotype_Map %>% filter(elem. == 'geneSymbols')
  Gene_Names <- rename(Gene_Names, c('Gene' = 'value.'))
  Gene_Names <- select(Gene_Names, -1)
  Gene_mimNumbers <- Phenotype_Map %>% filter(elem. == 'mimNumber')
  Gene_mimNumbers <- rename(Gene_mimNumbers, c('Gene_mimNumber' = 'value.'))
  Gene_mimNumbers <- select(Gene_mimNumbers, -1)
  Gene_Phenotype <- cbind(Locations, Phenotypes, Phenotype_mimNumbers, Phenotype_mapping_keys, Gene_Names, Gene_mimNumbers)
  return(Gene_Phenotype)
}
