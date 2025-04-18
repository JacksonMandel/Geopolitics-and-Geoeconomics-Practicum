# Check if packages are installed and install if necessary
if(!require(dplyr)){install.packages("dplyr")}
if(!require(readr)){install.packages("readr")}
if(!require(ggplot2)){install.packages("ggplot2")} # Also adding ggplot2

# Load the libraries
library(dplyr)
library(readr)
library(ggplot2)

# Define the file name as a variable for easy updates
file_name <- "sample.csv"  # Change to your actual file name
output_file <- paste0("VA_Shares_", file_name)

# Read the CSV file
tiva_data <- read_csv(file_name)

# Calculate the Partner Share of Value Added for ALL countries
tiva_data_with_shares <- tiva_data %>%
  # Group by exporting country, activity, and time period
  group_by(EXPORTING_AREA, EXPORTING_ACTIVITY, TIME_PERIOD) %>%
  # Calculate total world value (denominator) for each group
  mutate(
    # Store the World total for each group
    World_Total = sum(OBS_VALUE[VALUE_ADDED_SOURCE_AREA == "W"], na.rm = TRUE)
  ) %>%
  # Calculate value-added share for each country
  mutate(
    # Partner Share of Value Added = Country VA / World Total VA
    VA_Share = OBS_VALUE / World_Total
  ) %>%
  ungroup()

# Print verification info
cat("Number of rows in original data:", nrow(tiva_data), "\n")
cat("Number of rows in final data:", nrow(tiva_data_with_shares), "\n")
cat("Number of unique source countries:", n_distinct(tiva_data$VALUE_ADDED_SOURCE_AREA), "\n")
cat("Number of unique export activities:", n_distinct(tiva_data$EXPORTING_ACTIVITY), "\n")
cat("Year range:", min(tiva_data$TIME_PERIOD), "to", max(tiva_data$TIME_PERIOD), "\n\n")

# Print sample of results
cat("Sample of VA shares (first 10 rows):\n")
print(head(tiva_data_with_shares %>% 
             select(EXPORTING_AREA, VALUE_ADDED_SOURCE_AREA, EXPORTING_ACTIVITY, 
                    TIME_PERIOD, OBS_VALUE, World_Total, VA_Share) %>%
             arrange(EXPORTING_ACTIVITY, TIME_PERIOD, desc(VA_Share)), 10))

# Save final dataset
write_csv(tiva_data_with_shares, output_file)
cat("\nResults saved to", output_file, "\n")
