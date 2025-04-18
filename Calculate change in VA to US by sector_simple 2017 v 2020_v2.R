# Load required packages
if(!require(dplyr)){install.packages("dplyr")}
if(!require(readr)){install.packages("readr")}
# Load libraries
library(dplyr)
library(readr)
# Set file path - update this with your TiVA data file
file_path <- "1995 - 2020_CONS VA PSH_US only_all sectors_China.csv"
output_file <- paste0("CalculatedChngSimple_", file_path)
# Read the TiVA data
tiva_data <- read_csv(file_path)

# Calculate pre-trade war (2017) and post-trade war (2020) variance, simple
tiva_with_averages <- tiva_data %>%
  group_by(COUNTERPART_AREA, ACTIVITY) %>%
  mutate(
    VA_preTW = OBS_VALUE[TIME_PERIOD == 2017],
    VA_postTW = OBS_VALUE[TIME_PERIOD == 2020],
    va_change = VA_postTW - VA_preTW
  ) %>%
  ungroup()

# Create rankings using only 2020 data, but save them to use for all years
rankings <- tiva_with_averages %>%
  filter(TIME_PERIOD == 2020) %>%
  group_by(ACTIVITY) %>%
  mutate(
    sector_rank_grow = ifelse(va_change > 0, rank(-va_change, ties.method = "min"), NA),
    sector_rank_dip = ifelse(va_change < 0, rank(va_change, ties.method = "min"), NA)
  ) %>%
  select(COUNTERPART_AREA, ACTIVITY, sector_rank_grow, sector_rank_dip) %>%
  ungroup()

# Join rankings back to the full dataset
tiva_ranked <- tiva_with_averages %>%
  left_join(rankings, by = c("COUNTERPART_AREA", "ACTIVITY"))

# Save the enhanced dataset with all original data plus calculated values and rankings
write_csv(tiva_ranked, output_file)
print(paste("Analysis complete. Results saved to", output_file))