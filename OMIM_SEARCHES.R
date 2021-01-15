#####LETHAL OMIM SEARCH#####
#Obtain a dataframe of resulting mimNumbers from our search term
Lethal_MIMNumbers <- omim_search_results('lethal') 

#Apply our function across our mimNumbers to have a list of resulting dataframes 
DFLIST <- lapply(Lethal_MIMNumbers$mimNumber, OMIM_XML_DF) 

#Extracting the Phenotype-Gene information across all our DFLIST where appropriate within out DFLIST and converting
#that into a dataframe of relevant .
Lethal_GenePhenotypeMap <- lapply(DFLIST, Gene_Phenotype_Map) 
Lethal_GPMAP <- bind_rows(Lethal_GenePhenotypeMap) 

#Extracting the text from the 'Description' section across all of our Phenotype mimNumbers within our DFLIST 
Lethal_Descriptions <- lapply(DFLIST, DescriptionText)
Lethal_Description <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=Lethal_MIMNumbers$mimNumber, Description=Lethal_Descriptions))

#Extracting the text from the 'Clinical Features' section across all of our Phenotype mimNumbers within our DFLIST 
Lethal_ClinicalFeaturesText <- lapply(DFLIST, ClinicalFeaturesText)
Lethal_ClinFeatures <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=Lethal_MIMNumbers$mimNumber, Clinical_Features=Lethal_ClinicalFeaturesText))

#Extracting the text from the 'Clinical Synopsis' section across all of our Phenotype mimNumbers within our DFLIST 
Lethal_ClinicalSynopsisText <- lapply(DFLIST, ClinicalSynopsisText)
Lethal_ClinSynopsis <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=Lethal_MIMNumbers$mimNumber, Clinical_Synopsis=Lethal_ClinicalSynopsisText))

#Due to the way that the flatxml package structures the XML output of the API. The text entry of the clinical synopsis
#is structured differently compared to the other text fields. So we run this extra line to condense the multiple text 
#fields based on their corresponding mimNumber.
Lethal_ClinSynopsis <- setDT(Lethal_ClinSynopsis)[, .(Clinical_Synopsis = toString(Clinical_Synopsis)), Phenotype_mimNumber]

#We merge all of the existing datafames we've made above containing the gene phenotype map, description, clinical 
#features and clinical synopsis and combines them together as columns into a new dataframe.
LETHAL <- Reduce(merge, list(Lethal_GPMAP,Lethal_Description,Lethal_ClinFeatures,Lethal_ClinSynopsis))

#Add another column ot the dataframe to identify what search term was used to output this information.
LETHAL$Search_Term <- 'Lethal'

#Create dataframes consisting of TRUE/FLASE values based on whether grepl finds the search term within the
#Description, Clinical Features and Clinical Synopsis text fields.
Description_Filter <- as.data.frame(grepl("Lethal", LETHAL$Description, ignore.case = TRUE))
Clinical_Features_Filter <- as.data.frame(grepl("Lethal", LETHAL$Clinical_Features, ignore.case = TRUE))
Clinical_Synopsis_Filter <- as.data.frame(grepl("Lethal", LETHAL$Clinical_Synopsis, ignore.case = TRUE))

#Rename the column heading to be more human readable.
names(Description_Filter)[1] <- "Description_Filter"
names(Clinical_Features_Filter)[1] <- "Clinical_Features_Filter"
names(Clinical_Synopsis_Filter)[1] <- "Clinical_Synopsis_Filter"

#Add the filter columns to the dataframe containing the rest of our obtained OMIM information.
LETHAL <- cbind(LETHAL, Description_Filter, Clinical_Features_Filter, Clinical_Synopsis_Filter)

#Filter the dataframe to remove rows where all of the filters flag FALSE.
LETHAL <- LETHAL %>% filter(Description_Filter == 'TRUE' | Clinical_Features_Filter == 'TRUE' | Clinical_Synopsis_Filter == 'TRUE')

#####DIED OMIM SEARCH#####
Died_MIMNumbers <- omim_search_results('died')

#Occasionally, some searched terms will produce more than 2500 mimNumbers which is the base OMIM API limit unless you 
#specifically request for your limit to be raised. So to process through lists of mimNumbers larger than 2500 rows 
#we run the OMIM_XML_DF function in batches using batchtools.
library(batchtools)
btlapply(Died_MIMNumbers$mimNumber, OMIM_XML_DF, chunk.size = 100)

#Depending on the number of 'jobs' you need to process through we can use the blow command to check how many mimNumbers
#have been processed and/or failed due to API cap.
#getStatus() 

#To obtain the list of dataframes produced from our first batch.
DFLIST1 <- reduceResultsList() 

#To obtain the job ids that failed due to API cap.
Errors <- getErrorMessages() 

#Batchtools assigns each of our mimNumber in our initial list a 'job.id' in chronological order. As our unprocessed
#jobs are only reported back using their job.id. We assign our mimNumber list with job.id numbers so we can recall
#which mimNumbers need to be re-run the next day.
Died_MIMNumbers$job.id <- seq.int(nrow(Died_MIMNumbers)) #Adds job id numbers to our original MIMNumber list

#Merge the two tables to get the mimNumbers of our jobs that pulled up an error i.e. were rejected due to API cap.
ErrorTable <- merge(Died_MIMNumbers, Errors, by = 'job.id')

#Run another batch again the next day using the mimNumbers in the ErrorTable.
btlapply(ErrorTable$mimNumber, OMIM_XML_DF, chunk.size = 100)

#Obtain remaining list of dataframes. 
DFLIST2 <-  reduceResultsList() 

#Now to process this with the rest of our functions we need both the final DFLIST and mimNumbers to be in the same 
#order. FOr the functions to produce our intended output with no errors. FOr the DFLIST we can simply combine our two
#DFLISTs into a single one.
CorrectDFLIST <- do.call(c, list(DFLIST1, DFLIST2))

#For the mimNumbers, we already have the number from the second list. 
Second <- as.data.frame(ErrorTable$mimNumber)

#But we need to obtain the mimNumbers that were used for the first batch like so.
First <- Died_MIMNumbers %>% filter(!mimNumber %in% ErrorTable$mimNumber)

#After renaming some column headings for ease of human reading
names(First)[1] <- "mimNumber"
names(Second)[1] <- "mimNumber"

#We then simply combine them.
CorrectMIMNumberList <- rbind(First, Second)

#From there the rest of the script runs the same besides replacing the DFLIST and mimNumber lists with our corrected
#versions.
Died_GenePhenotypeMap <- lapply(CorrectDFLIST, Gene_Phenotype_Map)
Died_GPMAP <- bind_rows(Died_GenePhenotypeMap)

Died_Descriptions <- lapply(CorrectDFLIST, DescriptionText)
Died_Description <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=CorrectMIMNumberList$mimNumber, Description=Died_Descriptions))

Died_ClinicalFeaturesText <- lapply(CorrectDFLIST, ClinicalFeaturesText)
Died_ClinFeatures <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=CorrectMIMNumberList$mimNumber, Clinical_Features=Died_ClinicalFeaturesText))

Died_ClinicalSynopsisText <- lapply(CorrectDFLIST, ClinicalSynopsisText)
Died_ClinSynopsis <- do.call(rbind, Map(data.frame, Phenotype_mimNumber=CorrectMIMNumberList$mimNumber, Clinical_Synopsis=Died_ClinicalSynopsisText))
Died_ClinSynopsis <- setDT(Died_ClinSynopsis)[, .(Clinical_Synopsis = toString(Clinical_Synopsis)), Phenotype_mimNumber]

DIED <- Reduce(merge, list(Died_GPMAP,Died_Description,Died_ClinFeatures,Died_ClinSynopsis))
DIED$Search_Term <- 'died'

Description_Filter <- as.data.frame(grepl("died", DIED$Description, ignore.case = TRUE))
Clinical_Features_Filter <- as.data.frame(grepl("died", DIED$Clinical_Features, ignore.case = TRUE))
Clinical_Synopsis_Filter <- as.data.frame(grepl("died", DIED$Clinical_Synopsis, ignore.case = TRUE))

names(Description_Filter)[1] <- "Description_Filter"
names(Clinical_Features_Filter)[1] <- "Clinical_Features_Filter"
names(Clinical_Synopsis_Filter)[1] <- "Clinical_Synopsis_Filter"

DIED <- cbind(DIED, Description_Filter, Clinical_Features_Filter, Clinical_Synopsis_Filter)

DIED <- DIED %>% filter(Description_Filter == 'TRUE' | Clinical_Features_Filter == 'TRUE' | Clinical_Synopsis_Filter == 'TRUE')