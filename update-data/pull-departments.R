library(dplyr)
library(stringr)

data <- readxl::read_excel("./public/data/raw.xlsx")

listed <- data %>% 
  select(`Agency responsible for death`, State) %>% 
  filter(complete.cases(`Agency responsible for death`)) %>% 
  mutate(`Agency responsible for death` = ifelse(is.na(`Agency responsible for death`), 
                                                 'Unknown', 
                                                 `Agency responsible for death`),
         `Agency responsible for death` = str_replace_all(`Agency responsible for death`, 
                                                      ", ", 
                                                      replacement = paste0(" (", State, "), ")),
         `Agency responsible for death` = paste0(`Agency responsible for death`, " (", State, ")")) %>% 
  mutate(all_agencies = as.list(strsplit(`Agency responsible for death`, ", "))) %>% 
  select(all_agencies)

long <- tidyr::unnest(listed, all_agencies) %>% 
  filter(complete.cases(.))

departments <- long %>% 
  distinct(all_agencies)

readr::write_csv(departments, "./public/data/departments.csv")
