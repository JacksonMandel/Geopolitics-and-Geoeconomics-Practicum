# Install and load required packages
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
# Define the file name as a variable for easy updates
file_name <- "test dataset.csv"
output_file <- paste0("Decoded_", file_name)

# Load TiVA dataset
tiva_data <- read.csv(file_name, stringsAsFactors = FALSE)

# Country Codes Lookup Table
country_mapping <- data.frame(
  Code = c("AUS", "AUT", "BEL", "CAN", "CHL", "COL", "CRI", "CZE", "DNK", "EST", 
           "FIN", "FRA", "DEU", "GRC", "HUN", "ISL", "IRL", "ISR", "ITA", "JPN",
           "KOR", "LVA", "LTU", "LUX", "MEX", "NLD", "NZL", "NOR", "POL", "PRT",
           "SVK", "SVN", "ESP", "SWE", "CHE", "TUR", "GBR", "USA", "ARG", "BRA",
           "BRN", "BGR", "KHM", "CHN", "HRV", "CYP", "HKG", "IDN", "IND", "KAZ",
           "MYS", "MLT", "MAR", "PER", "PHL", "ROU", "RUS", "SAU", "SGP", "ZAF",
           "TWN", "THA", "TUN", "UKR", "VNM", "WXD", "BGD", "BLR", "CIV", "CMR", 
           "EGY", "JOR", "LAO", "MMR", "NGA", "PAK", "SEN"),
  Full_Name = c("Australia", "Austria", "Belgium", "Canada", "Chile", "Colombia", 
                "Costa Rica", "Czechia", "Denmark", "Estonia", "Finland", "France",
                "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Israel", "Italy",
                "Japan", "Korea", "Latvia", "Lithuania", "Luxembourg", "Mexico",
                "Netherlands", "New Zealand", "Norway", "Poland", "Portugal", "Slovakia",
                "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", 
                "United Kingdom", "United States", "Argentina", "Brazil", "Brunei",
                "Bulgaria", "Cambodia", "China", "Croatia", "Cyprus", "Hong Kong",
                "Indonesia", "India", "Kazakhstan", "Malaysia", "Malta", "Morocco",
                "Peru", "Philippines", "Romania", "Russia", "Saudi Arabia",
                "Singapore", "South Africa", "Chinese Taipei", "Thailand", "Tunisia",
                "Ukraine", "Viet Nam", "Rest of the World", "Bangladesh", "Belarus", 
                "Cote d'Ivoire", "Cameroon", "Egypt", "Jordan", "Laos", 
                "Myanmar", "Nigeria", "Pakistan", "Senegal"),
  stringsAsFactors = FALSE
)

# Group Codes Lookup Table - Fixed number of rows
group_mapping <- data.frame(
  Code = c("OECD", "WXOECD", "ASEAN", "S2", "EU27_2020", "EU28", "EU15",
           "EU28XEU15", "EA19", "G20", "E", "S2_S8", "NAFTA", "A5_A7", "F",
           "W", "D", "W_O", "APEC"),
  Full_Name = c("OECD member countries", "Non-OECD economies", 
                "Association of Southeast Asian Nations", "East and Southeast Asia",
                "European Union (27 countries)", "European Union (28 countries)",
                "European Union (15 countries)", "European Union (13 countries)",
                "Euro area (19 countries)", "G20 countries", "Europe",
                "Asia and Pacific", "North American Free Trade Agreement",
                "South and Central America", "Africa", "World",
                "Domestic", "Other regions",
                "Asia-Pacific Economic Cooperation"),
  stringsAsFactors = FALSE
)

# Industry mapping with corrected row counts
activity_codes <- rbind(
  # Detailed industry codes
data.frame(
  Code = c("A01_02", "A03", "BTE", "B", "B05_06", "B07_08", "B09", "C", 
           "C10T12", "C13T15", "C16T18", "C16", "C17_18", "C19T23", "C19", "C20_21", "C20", "C21", 
     "C22", "C23", "C24_25", "C24", "C25", "C26_27", "C26", "C27", "C28", "C29_30", 
     "C29", "C30", "C31T33", "D_E", "D", "E", "FTT", "F", "GTT", "GTN", 
     "GTI", "G", "H", "H49", "H50", "H51", "H52", "H53", "I", "JTN", 
     "J","J58T60", "J61", "J62_63", "K", "L", "M_N", "M", "N", "OTT", 
     "OTQ", "O", "P", "Q", "RTT", "R_S", "R", "S", "T", "INFO"),
  Full_Name = c("4_Agriculture, hunting, forestry", 
               "4_Fishing and aquaculture", 
           "1_Industry (Mining, Manurfactures, and Utilites)", 
                "3_Mining and quarrying", 
                   "4_Mining of energy producing products", 
                   "4_Mining of non-energy producing products", 
                   "4_Mining support services", 
           "3_Total Manufacturing", 
              "4_Food products, beverages and tobacco", 
              "4_Textiles, textile products, leather and footwear", 
              "4_Wood and paper products and printing",
                 "5_Wood and products of wood and cork",
                 "5_Paper products and printing",  
              "4_Chemicals and non-metallic mineral products",
                 "5_Coke and refined petroleum products", 
                 "5_Chemicals an pharmaceutical products",
                    "6_Chemical and chemical products", 
                    "6_Pharmaceuticals", 
                 "5_Rubber and plastics products", 
                 "5_Other non-metallic mineral products", 
              "4_Basic metals and fabricated metal products",
                 "5_Basic metals", 
                 "5_Fabricated metal products", 
              "4_Computer, electronic and electrical equipment",
                 "5_Computer, electronic and optical equipment", 
                 "5_Electrical equipment", 
              "4_Other Machinery and equipment", 
              "4_Transport equipment",
                 "5_Motor vehicles, trailers and semi-trailers", 
                 "5_Other transport equipment", 
             "4_Other manufacturing; repair and installation", 
          "3_Electricity, gas, water supply, sewerage, waste and remediation services",
                "4_Electricity, gas, steam and air conditioning supply", 
                "4_Water supply; sewerage, waste management and remediation activities", 
    "1_Total Services (including Construction)",
         "3_Construction",
      "2_Total Services (excluding Construction)",
         "3_Total Business sector services",
            "4_Distributive trade, transport, accomodation, and food services", 
               "5_Wholesale and retail trade, repair of motor vehicles", 
               "5_Transportation and storage", 
                   "6_Land transport and pipelines", 
                   "6_Water transport", 
                   "6_Air transport", 
                   "6_Warehousing and support activities", 
                   "6_Postal and courier activities", 
                "5_Accommodation and food service activities", 
  "1_Information, finance, real estate and other business services", 
           "4_Information and communication",   
                "5_Publishing, audiovisual and broadcasting activities", 
                "5_Telecommunications", 
                "5_IT and other information services", 
           "4_Financial and insurance activities", 
           "4_Real estate activities", 
           "4_Other business sector services",
               "5_Professional, scientific and technical activities", 
               "5_Administrative and support services",
        "3_Public admin, education, health, and other personal services",
           "4_Public admin, defence; education, and health",
              "5_public admin and defence; compulsory social security",
              "5_Education", 
              "5_Human health and social work activities", 
          "4_Other social and personal services", 
              "5_Other community, social and personal services",
                  "6_Arts, entertainment and recreation", 
                  "6_Other service activities", 
              "5_Activities of households as employers", 
       "2_Information industries"),
  Type = "industry",  
    stringsAsFactors = FALSE
  ),
  # Aggregate codes
  data.frame(
      Code = c("_T", "A"),
  Full_Name = c("0_TOTAL All Divisions", "3_Agriculture, hunting, forestry and fishing"),
  Type = "aggregate",
    stringsAsFactors = FALSE
  )
)

# Improved replacement function with exact matching
replace_codes_exact <- function(data, column, lookup_table) {
  # Create pattern with word boundaries
  patterns <- paste0("^", lookup_table$Code, "$")
  
  # For each value in the column
  result <- data[[column]]
  for(i in seq_along(patterns)) {
    # Replace only exact matches
    result[grepl(patterns[i], result)] <- lookup_table$Full_Name[i]
  }
  return(result)
}

# Apply replacements with improved order and exact matching
tiva_data <- tiva_data %>%
  mutate(
    # Handle industries first, with detailed codes before aggregates
    ACTIVITY = replace_codes_exact(., "ACTIVITY", 
                                 activity_codes[activity_codes$Type == "industry",]),
)
tiva_data <- tiva_data %>%
  mutate(
    # Handle industry aggregates
    ACTIVITY = replace_codes_exact(., "ACTIVITY", 
                                 activity_codes[activity_codes$Type == "aggregate",]),
    # Handle geographic codes
    REF_AREA = ifelse(REF_AREA %in% country_mapping$Code, country_mapping$Full_Name[match(REF_AREA, country_mapping$Code)], REF_AREA),
    COUNTERPART_AREA = ifelse(COUNTERPART_AREA %in% country_mapping$Code, country_mapping$Full_Name[match(COUNTERPART_AREA, country_mapping$Code)], COUNTERPART_AREA),
    REF_AREA = ifelse(REF_AREA %in% group_mapping$Code, group_mapping$Full_Name[match(REF_AREA, group_mapping$Code)], REF_AREA),
    COUNTERPART_AREA = ifelse(COUNTERPART_AREA %in% group_mapping$Code, group_mapping$Full_Name[match(COUNTERPART_AREA, group_mapping$Code)], COUNTERPART_AREA),
  )

# Save cleaned dataset with updated filename
write.csv(tiva_data, output_file, row.names = FALSE)
print(paste("File saved as:", output_file))