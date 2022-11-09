rm(list = ls(all = T))

pacman::p_load(readxl, tidyverse, patchwork, wesanderson, gratia, rjags, runjags, HDInterval, lme4)

setwd('/Users/ball4364/Desktop/Malaria/Data/Our data/')

source('../Functions/composite_models.R')

read_csv('complete_data.csv', guess_max = 10000) %>%
  mutate(Site = ifelse(Site == 'Junju (Kilifi B)', 'Kilifi B', Site),
         Site = ifelse(Site == "Kadziununi-Mauveni (Kilifi C)", 'Kilifi C', Site),
         Site = ifelse(Site == 'Ngerenya (Kilifi A)', 'Kilifi A', Site),
         Study_ID = paste(Site, Period, sep = ' '),
         Study_Number = as.numeric(as.factor(Study_ID))) %>%
  dplyr::select(Site, Study_ID, Study_Number, Period, 
                Hb_level, Deep_breathing, Unconscious_Observed, APVU, BCS,
                Inter_costal_recession, 
                Pallor, Blood_transfusion, 
                Total_Population) -> all_data

###########
# SURVYES #

read_csv('complete_data.csv') %>%
  group_by(Site, Period) %>%
  distinct(Detection_Method) %>%
  mutate(Site = ifelse(Site == "Junju (Kilifi B)", 'Kilifi B', Site),
         Site = ifelse(Site == "Kadziununi-Mauveni (Kilifi C)", 'Kilifi C', Site),
         Site = ifelse(Site == "Ngerenya (Kilifi A)", 'Kilifi A', Site),
         Detection_Method = ifelse(Detection_Method == 'Microsopy', 'Microscopy', Detection_Method)) -> sampling_data

read_xlsx('Parasite_surveys.xlsx') %>%
  separate(Site, into = c('Site', 'Country'), sep = ',') %>%
  mutate(Country = gsub(pattern = ' ', replacement = '', Country),
         Study_ID = paste(Site, Period, sep = ' '),
         Study_Number = as.numeric(as.factor(Study_ID)),
         Min_Age  = round(Min_Age) + 1, 
         Max_Age = round(Max_Age) + 1,
         Max_Age = ifelse(Max_Age > 85, 85, Max_Age)) %>%
  left_join(sampling_data) %>%
  arrange(Study_Number) -> formatted_surveys 

save(formatted_surveys, file = '../Output/formatted_surveys.RData')

formatted_surveys %>%
  group_by(Study_Number, Number, Positives, ) %>%
  summarise(mn = Min_Age - 1,
            mx = Max_Age - 1 , 
            PR = sum(Positives / Number) / n()) %>%
  ungroup() -> converted_pr_determ

