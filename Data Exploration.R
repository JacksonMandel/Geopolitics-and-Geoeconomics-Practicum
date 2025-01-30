
#Data Opening and Exploration

#Setup

library(tidyverse)
library(kableExtra)
library(dplyr)
library(haven)
library(ggplot2)

#Importing OECD Data on Intermediate, Final, and Gross Imports

data <- readr::read_csv('ImportData.csv')

df_wide <- pivot_wider(data, names_from = MEASURE, values_from = OBS_VALUE)

#Creating new data columns for final and intermediate imports as a percentage of gross imports

df_wide$IntImpPer <- (df_wide$IMGR_INT / df_wide$IMGR) * 100

df_wide$FinImpPer <- (df_wide$IMGR_FNL / df_wide$IMGR) * 100

ggplot(df_wide, aes(x = TIME_PERIOD, y = FinImpPer, fill = "Finished Goods")) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_bar(aes(y = IntImpPer, fill = "Intermediate Goods"), stat = "identity", position = "dodge") +
  facet_wrap(~ REF_AREA) +  # One panel per country
  labs(title = "Proportion of Finished and Intermediate Goods by Year",
       y = "Percentage of Total Imports",
       x = "Year",
       fill = "Import Type") +
  scale_fill_manual(values = c("Finished Goods" = "steelblue", "Intermediate Goods" = "orange")) +
  theme_minimal()

writeLines(file_text, "DATA-EXPLORATION.Rmd", useBytes = TRUE)
