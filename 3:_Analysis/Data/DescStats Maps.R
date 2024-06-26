# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HEC Project
# *Data: Panel_v1.dta + shapefile
# *Stage: Descriptive Stats
# 
# *Last checked: 06.04.2024
# 
# /*
# ******************************************************************************
# *                                 Contents                                   *
# ******************************************************************************
#   
# This script aims to ....
#
#
#    
# 
#     Output:
#       - Figures
# 
# ******************************************************************************
# Clear the Environment
# ---------------------------------------------------------------------------- #

rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
library(tidyverse)  # Essentials
library(readxl)     # For reading Excel files
library(openxlsx)   # For exporting Excel files
library(haven)      # For Stata files
library(sf)         # For spatial data
library(scales)
# ---------------------------------------------------------------------------- #
# Data Import: Spatial Data
# ---------------------------------------------------------------------------- #
zip_file_path <- "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/1:_RawData/Shapefile/Municipios.zip"
extraction_directory <- "/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/1:_RawData/Shapefile/Extracted"

# Corrected argument name
unzip(zip_file_path, exdir = extraction_directory)

# Adjust the path to where you've extracted the .shp file
shapefile_path <- paste0(extraction_directory, "/Servicios_P%C3%BAblicos_-_Municipios.shp")

# Read the shapefile
mun <- st_read(shapefile_path)

mun <- mun %>%
  mutate(
    # Ensure the department code is treated as a two-digit string
    DPTO_CCDGO = sprintf("%02d", as.numeric(DPTO_CCDGO)),
    # Ensure the municipality code is treated as a three-digit string
    MPIO_CCDGO = sprintf("%03d", as.numeric(MPIO_CCDGO)),
    # Concatenate the formatted strings to create the new ID
    id = paste0(DPTO_CCDGO, MPIO_CCDGO)
  )

# ---------------------------------------------------------------------------- #
# Data Import: Stata Data
# ---------------------------------------------------------------------------- #
df <- read_dta("/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/2:_ProcessedData/MergedData/Final/Panel_v1.dta")

df <- df %>%
  mutate(
    id = sprintf("%05d", as.numeric(id))
  )


# ---------------------------------------------------------------------------- #
# Data Map: Violence Across Municipalities
# ---------------------------------------------------------------------------- #

# Grouping by year
df_summary <- df %>%
  group_by(id) %>%
  summarise(
    total_violence = sum(NumABel, NumSecuestros, NumATerror, NumASelect, NumAPob, na.rm = TRUE) +
      sum(NumABel, na.rm = TRUE) +
      sum(NumSecuestros, na.rm = TRUE) +
      sum(NumATerror, na.rm = TRUE) +
      sum(NumASelect, na.rm = TRUE) +
      sum(NumAPob, na.rm = TRUE), 
    .groups = 'drop'
  )

merged_data <- mun %>%
  left_join(df_summary, by = "id")

# Plotting
violence_plot <- ggplot(data = merged_data) +
  geom_sf(aes(fill = total_violence), color = NA) + 
  scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "lightgrey", 
                      name = "Índice de Violencia") +
  labs(title = "Violencia a Nivel Municipal",
       subtitle = "Pooled (1972-1990)") +
  theme_minimal() +
  theme(legend.position = "right",
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank())

print(violence_plot)

ggsave("/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/4:_Output/Figures/Viol_Mun.pdf", plot = violence_plot, width = 10, height = 8, dpi = 300)



# ---------------------------------------------------------------------------- #
# Data Map: Votes & Parties Across Municipalities
# ---------------------------------------------------------------------------- #

# Aggregate votes
df_summary2 <- df %>%
  group_by(id) %>%
  summarise(
    diff_votes = sum(PARTIDOLIBERALCOLOMBIANO, na.rm = TRUE) - sum(PARTIDOCONSERVADORCOLOMBIANO, na.rm = TRUE),
    .groups = 'drop'
  )

# Merging
merged_data <- mun %>%
  left_join(df_summary2, by = "id")

# Plot

# Calculate the 5th and 95th percentiles of diff_votes
p5 <- quantile(merged_data$diff_votes, probs = 0.01, na.rm = TRUE)
p95 <- quantile(merged_data$diff_votes, probs = 0.99, na.rm = TRUE)

# Plot
political_leaning_plot <-  ggplot(data = merged_data) +
  geom_sf(aes(fill = diff_votes), color = NA) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "purple",
                       midpoint = 0, limits = c(p5, p95), na.value = "grey",  # Set NA values to light grey
                       name = "Inclinación Política") +
  labs(title = "Inclinación Política de los Municipios Colombianos",
       subtitle = "Rojo: Partido Liberal Colombiano, Azul: Partido Conservador Colombiano\nCompetitividad basada en la diferencia de votos (1972-1990)",
       caption = paste("Escala limitada desde el percentil del 1% hasta el percentil del 99%")) +
  theme_minimal() +
  theme(legend.position = "right",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title = element_text(size = 16, face = "bold", margin = margin(b = 20)),
        plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
        plot.caption = element_text(size = 8, margin = margin(t = 10)))

print(political_leaning_plot)

#  save the plot
ggsave("/Users/edmundoarias/Documents/Uniandes/2024-10/HEC/Political-Attitudes/4:_Output/Figures/Inc_Pol.pdf", plot = political_leaning_plot, width = 10, height = 8, dpi = 300)



