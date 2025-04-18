# Check if packages are installed and install if necessary
if(!require(dplyr)){install.packages("dplyr")}
if(!require(readr)){install.packages("readr")}
if(!require(ggplot2)){install.packages("ggplot2")} # Also adding ggplot2

# Load the libraries
library(dplyr)
library(readr)
library(ggplot2)

# Define the file name as a variable for easy updates
file_name <- "TEST calculations.csv"
output_file <- paste0("Calculated_", file_name)

# Read the CSV file (replace with your actual file path)
tiva_data <- read_csv(file_name)

# Calculate the PSH_chn va

tiva_data_with_fractions <- tiva_data %>%
  group_by(EXPORTING_AREA, EXPORTING_ACTIVITY, TIME_PERIOD) %>% # Group by these variables
  mutate(PSH_chn_va = ifelse(
           VALUE_ADDED_SOURCE_AREA == "CHN",  # Only calculate for China rows
           OBS_VALUE / sum(OBS_VALUE[VALUE_ADDED_SOURCE_AREA == "W"], na.rm = TRUE), # Calculate the PSH_chn_va, handling NAs
           NA # Assign NA to World rows for the new PSH_chn_va column
         )) %>%
  ungroup()


# Print a summary or first few rows to check
print(summary(tiva_data_with_fractions))
print(head(tiva_data_with_fractions))
# Further Analysis (example)

# You can now analyze the 'PSH_chn_va' column. For example, to get average PSH_chn_va by exporting industry:
average_fractions <- tiva_data_with_fractions %>%
  filter(VALUE_ADDED_SOURCE_AREA == "CHN") %>% # Filter only the China rows as those have the calculated PSH_chn_va
  group_by(EXPORTING_ACTIVITY) %>%
  summarize(mean_PSH_chn_va = mean(PSH_chn_va, na.rm = TRUE))

print(average_fractions)


# Calculate pre- and post-2017 averages (as before)
tiva_data_with_averages <- tiva_data_with_fractions %>%
  filter(VALUE_ADDED_SOURCE_AREA == "CHN") %>% # Keep only CHN rows for averages
  group_by(EXPORTING_AREA, EXPORTING_ACTIVITY) %>%
  mutate(
    pre_TW_Avg = ifelse(TIME_PERIOD == 2020, mean(PSH_chn_va[TIME_PERIOD >= 2013 & TIME_PERIOD <= 2017], na.rm = TRUE), NA),
    post_TW_avg = ifelse(TIME_PERIOD == 2020, mean(PSH_chn_va[TIME_PERIOD >= 2018 & TIME_PERIOD <= 2020], na.rm = TRUE), NA)
  ) %>%
  ungroup()

# Join with the original data (to keep all rows)
tiva_data_final <- left_join(tiva_data_with_fractions, tiva_data_with_averages %>% select(EXPORTING_AREA, EXPORTING_ACTIVITY, TIME_PERIOD, pre_TW_Avg, post_TW_avg), by = c("EXPORTING_AREA", "EXPORTING_ACTIVITY", "TIME_PERIOD"))

# Calculate the change *after* the join
tiva_data_final <- tiva_data_final %>%
  group_by(EXPORTING_AREA, EXPORTING_ACTIVITY) %>%
  mutate(change = ifelse(TIME_PERIOD == 2020 & VALUE_ADDED_SOURCE_AREA == "CHN", post_TW_avg - pre_TW_Avg, NA)) %>% # Calculate change only for 2020 CHN rows
  ungroup() %>%
  mutate(change = abs(change)) # Take the absolute value


# Rank countries (excluding specified groups) - Corrected!
excluded_groups <- c("CHN", "G20", "APEC", "S2", "S2_S8", "W", "WXOECD")

tiva_data_ranked <- tiva_data_final %>%  # Use tiva_data_final here!
  filter(VALUE_ADDED_SOURCE_AREA == "CHN" & !EXPORTING_AREA %in% excluded_groups) %>%
  group_by(EXPORTING_ACTIVITY) %>%  # Rank within each sector
  mutate(PostTW_change_rank = ifelse(TIME_PERIOD == 2020, rank(desc(change)), NA)) %>% # Rank only the 2020 rows
  ungroup()

# Join the ranked data back to tiva_data_final (Recommended)
tiva_data_final <- left_join(tiva_data_final, tiva_data_ranked %>% select(EXPORTING_AREA, EXPORTING_ACTIVITY, TIME_PERIOD, PostTW_change_rank), by = c("EXPORTING_AREA", "EXPORTING_ACTIVITY", "TIME_PERIOD"))

# Print and save the final data
print(head(tiva_data_final))
write_csv(tiva_data_final, output_file)

# Preview the rank column (first 5 values for each exporting activity)
print(tiva_data_ranked %>% 
        filter(!is.na(PostTW_change_rank)) %>% # Filter out non-ranked rows
        group_by(EXPORTING_ACTIVITY) %>%
        slice_head(n = 5) %>% # Take the first 5 rows for each group
        select(EXPORTING_AREA, EXPORTING_ACTIVITY, TIME_PERIOD, PostTW_change_rank) %>% # Select relevant columns
        arrange(EXPORTING_ACTIVITY, PostTW_change_rank)) #Optional: arrange by sector and rank