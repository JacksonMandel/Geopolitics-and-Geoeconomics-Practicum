
#Data Opening and Exploration

library(tidyverse)
library(kableExtra)
library(dplyr)
library(haven)

df <- readr::read_csv('OECD.STI.PIE_DSD_TIVA_MAINLV@DF_MAINLV_1_0.csv')