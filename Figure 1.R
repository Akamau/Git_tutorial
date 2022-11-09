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