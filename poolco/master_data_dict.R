#Build data dict for pooled cohorts

rm(list=ls())

library(data.table)
library(plyr)
library(dplyr)

#Set directories and get list of cohorts

dir <- "J:/WORK/05_risk/pooled_cohorts/dbs/"

master  <- fread(paste0(dir, "/master_codebook/master_dict.csv"))
cohorts <- list.files(paste0(dir, "cohort_codebooks/"))

#For each cohort, build up dictionary of relevant, between-cohort, indicators. 

setwd(paste0(dir, "cohorts/"))
for (cohort in cohorts){
    
    cohort_name <- gsub("_data_dict.csv", "", cohort)
    cohort_df   <- fread(cohort)  
    
    #Manually tag indicator type. Add indicator types to master, as well as associated variable from the cohort.
    #If indicator added to the master list does not have a cohort id, create one.
    
    hash <- unique(cohort_df$pc_indicator_name) %>%
            .[!unique(cohort_df$pc_indicator_name) %in% unique(master$pc_indicator_name)] %>%
            sort
    
    for (indicator in hash){
      
        i <- max(master$pc_indicator_id) + 1
        
        new_indicator <- data.table(pc_indicator_name = indicator, pc_indicator_id = i)
        master <- rbind(master, new_indicator, fill = T)
        
    }
    
    #Add on master codebook information to cohort datadict and save 
    cohort_df <- join(cohort_df, master, by="pc_indicator_name", type="left")
    write.csv(cohort_df, paste0(cohort_name, "_data_dict.csv"), row.names = F)
}

#Save new master data dict
write.csv(master, paste0(dir, "/master/master_dict.csv"), row.names=F)