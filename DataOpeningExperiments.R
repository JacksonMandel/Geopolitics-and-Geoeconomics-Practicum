
#Data Opening and Exploration

#Setup

library(tidyverse)
library(kableExtra)
library(dplyr)
library(haven)
library(ggplot2)

#Importing OECD Data on Intermediate, Final, and Gross Imports

data <- readr::read_csv('Intermediate Final and Gross Imports.csv')

df_wide <- pivot_wider(data, names_from = MEASURE, values_from = OBS_VALUE)

china_hk <- df_wide %>%
  filter(REF_AREA %in% c("CHN", "HKG")) %>%
  group_by(TIME_PERIOD, DATAFLOW, ACTION, ACTIVITY, COUNTERPART_AREA, UNIT_MEASURE,
           FREQ, UNIT_MULT, CONTACT, DATA_COMP) %>%
  summarise(
    REF_AREA = "CHN+HKG",
    IMGR = sum(IMGR, na.rm = TRUE),
    IMGR_FNL = sum(IMGR_FNL, na.rm = TRUE),
    IMGR_INT = sum(IMGR_INT, na.rm = TRUE),
    .groups = "drop"
  )
df_wide %>%
filter(!REF %in% c("CHN", "HGK")) %>%  # Remove individual rows
df_combined <- bind_rows(df_wide, china_hk)

#Creating new data columns for final and intermediate imports as a percentage of gross imports

df_combined$IntImpPer <- (df_combined$IMGR_INT / df_wide$IMGR) * 100

df_combined$FinImpPer <- (df_combined$IMGR_FNL / df_wide$IMGR) * 100

ggplot(df_combined, aes(x = TIME_PERIOD, y = FinImpPer, fill = "Finished Goods")) +
  geom_bar(stat = "identity") +
  geom_bar(aes(y = IntImpPer, fill = "Intermediate Goods"), stat = "identity") +
  facet_wrap(~ REF_AREA) +  # One panel per country
  labs(title = "Proportion of Finished and Intermediate Goods by Year",
       y = "Percentage of Total Imports",
       x = "Year",
       fill = "Import Type") +
  scale_fill_manual(values = c("Finished Goods" = "steelblue", "Intermediate Goods" = "orange")) +
  theme_minimal()

