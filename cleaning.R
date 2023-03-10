library(tigris)
library(tidyverse)
library(urbnthemes)
library(sf)
library(tidycensus)

set_urbn_defaults(style = "map")
options(tigris_class = "sf")
census_api_key('API KEY', install=TRUE)

### import raw data ###
dc_bg_raw <- block_groups(
  state = "DC",
  cb = TRUE,
  year = 2021
) 

dc_tracts_raw <- tracts(
  state = 'DC',
  cb = TRUE,
  year = 2021
)

dc_state <- states(
  cb = TRUE,
  year = 2021
) %>%
  filter(STUSPS == 'DC') 

dc_wards <- st_read('Wards_from_1992/Wards_from_1992.shp') 

ch_landmarks_raw <- read_csv('data/raw/congress_heights_landmarks-geocoded.csv') 

# variables of interest
v21 <- load_variables(2021, "acs5", cache = TRUE)

vars <- c(
  med_hh_inc = "B19013_001",  # median household income estimate
  total_age = "B01001_001",
  m_total_age = "B01001_002",
  m_under5 = "B01001_003",
  m_5to9 = "B01001_004",
  m_10to14 = "B01001_005",
  m_15to17 = "B01001_006",
  m_18to19 = "B01001_007",
  m_20 = "B01001_008",
  m_21 = "B01001_009",
  m_22to24 = "B01001_010",
  m_25to29 = "B01001_011",
  m_30to34 = "B01001_012",
  m_35to39 = "B01001_013",
  m_40to44 = "B01001_014",
  m_45to49 = "B01001_015",
  m_50to54 = "B01001_016",
  m_55to59 = "B01001_017",
  m_60and61 = "B01001_018",
  m_62to64 = "B01001_019",
  m_65and66 = "B01001_020",
  m_67to69 = "B01001_021",
  m_70to74 = "B01001_022",
  m_75to79 = "B01001_023",
  m_80to84 = "B01001_024",
  m_85plus = "B01001_025",
  f_total_age = "B01001_026",
  f_under5 = "B01001_027",
  f_5to9 = "B01001_028",
  f_10to14 = "B01001_029",
  f_15to17 = "B01001_030",
  f_18to19 = "B01001_031",
  f_20 = "B01001_032",
  f_21 = "B01001_033",
  f_22to24 = "B01001_034",
  f_25to29 = "B01001_035",
  f_30to34 = "B01001_036",
  f_35to39 = "B01001_037",
  f_40to44 = "B01001_038",
  f_45to49 = "B01001_039",
  f_50to54 = "B01001_040",
  f_55to59 = "B01001_041",
  f_60and61 = "B01001_042",
  f_62to64 = "B01001_043",
  f_65and66 = "B01001_044",
  f_67to69 = "B01001_045",
  f_70to74 = "B01001_046",
  f_75to79 = "B01001_047",
  f_80to84 = "B01001_048",
  f_85plus = "B01001_049"
)
  
demographics_raw <- get_acs(geography = "block group", 
                       variables = vars, 
                       state = '11',
                       year = 2021,
                       survey = 'acs5',
                       geometry = TRUE)

demographics <- demographics_raw %>%
  pivot_wider(names_from = 'variable', values_from = c('estimate','moe')) %>%
  filter(GEOID %in% c('110010073041','110010073042','110010073043',
                      '110010098041','110010098042')) %>%
  mutate(total_under5 = estimate_m_under5 + estimate_f_under5,
         total_5to9 = estimate_m_5to9 + estimate_f_5to9,
         total_10to14 = estimate_m_10to14 + estimate_f_10to14,
         total_15to17 = estimate_m_15to17 + estimate_f_15to17,
         total_18to19 = estimate_m_18to19 + estimate_f_18to19,
         total_20 = estimate_m_20 + estimate_f_20,
         total_21 = estimate_m_21 + estimate_f_21,
         total_22to24 = estimate_m_22to24 + estimate_f_22to24,
         total_25to29 = estimate_m_25to29 + estimate_f_25to29,
         total_30to34 = estimate_m_30to34 + estimate_f_30to34,
         total_35to39 = estimate_m_35to39 + estimate_f_35to39,
         total_40to44 = estimate_m_40to44 + estimate_f_40to44,
         total_45to49 = estimate_m_45to49 + estimate_f_45to49,
         total_50to54 = estimate_m_50to54 + estimate_f_50to54,
         total_55to59 = estimate_m_55to59 + estimate_f_55to59,
         total_60and61 = estimate_m_60and61 + estimate_f_60and61,
         total_62to64 = estimate_m_62to64 + estimate_f_62to64,
         total_65and66 = estimate_m_65and66 + estimate_f_65and66,
         total_67to69 = estimate_m_67to69 + estimate_f_67to69,
         total_70to74 = estimate_m_70to74 + estimate_f_70to74,
         total_75to79 = estimate_m_75to79 + estimate_f_75to79,
         total_80to84 = estimate_m_80to84 + estimate_f_80to84,
         total_85plus = estimate_m_85plus + estimate_f_85plus,
         perc_under5 = total_under5/estimate_total_age,
         perc_5to9 = total_5to9/estimate_total_age,
         perc_10to14 = total_10to14/estimate_total_age,
         perc_15to17 = total_15to17/estimate_total_age,
         perc_18to19 = total_18to19/estimate_total_age,
         perc_20 = total_20/estimate_total_age,
         perc_21 = total_21/estimate_total_age,
         perc_22to24 = total_22to24/estimate_total_age,
         perc_25to29 = total_25to29/estimate_total_age,
         perc_30to34 = total_30to34/estimate_total_age,
         perc_35to39 = total_35to39/estimate_total_age,
         perc_40to44 = total_40to44/estimate_total_age,
         perc_45to49 = total_45to49/estimate_total_age,
         perc_50to54 = total_50to54/estimate_total_age,
         perc_55to59 = total_55to59/estimate_total_age,
         perc_60and61 = total_60and61/estimate_total_age,
         perc_62to64 = total_62to64/estimate_total_age,
         perc_65and66 = total_65and66/estimate_total_age,
         perc_67to69 = total_67to69/estimate_total_age,
         perc_70to74 = total_70to74/estimate_total_age,
         perc_75to79 = total_75to79/estimate_total_age,
         perc_80to84 = total_80to84/estimate_total_age,
         perc_85plus = total_85plus/estimate_total_age) %>%
  select(-contains('estimate'),
         -contains('moe')) 

demographics_long <- demographics %>%
  pivot_longer(cols = starts_with("perc"),
               names_to = "age_group",
               names_prefix = "perc_",
               values_to = "percentage") %>%
  mutate(generation_cat = case_when(age_group %in% c("under5","5to9","10to14","15to17","18to19","20","21") ~ "21 and under",
                                    age_group %in% c("22to24","25to29","30to34","35to39","40to44","45to49","50to54") ~ "Over 21 and under 55",
                                    age_group %in% c("55to59","60and61","62to64","65and66","67to69","70to74","75to79") ~ "Over 55 and under 80",
                                    age_group %in% c("80to84","85plus") ~ "Over 80")) %>%
  separate(NAME, 
           into = c("block_group","tract","county","state"),
           sep = ",")

write_csv(demographics_long, "data/clean/ch_agegroups.csv")

# clean raw data
ch_bg <- dc_bg_raw %>%
  filter(TRACTCE == '007304' & BLKGRPCE %in% c('1','2','3') | TRACTCE == '009804' & BLKGRPCE %in% c('1','2')) %>%
  st_transform(crs = 'WGS84') %>%
  mutate(RegionAbbr = 'DC')

ch_tracts <- dc_tracts_raw %>%
  filter(TRACTCE == '007304' | TRACTCE == '009804') 

ch_landmarks <- ch_landmarks_raw %>%
  select('Category/Description','Name','Match_addr','Longitude','Latitude','RegionAbbr','geometry')

ward8 <- dc_wards %>%
  filter(WARD == 8)

civic_institutions <- ch_bg %>%
  left_join(ch_landmarks, by='RegionAbbr')
  
### save cleaned data
write_csv(ch_bg, 'data/clean/ch_bg.csv')
write_csv(ch_tracts, 'data/clean/ch_tracts.csv')
write_csv(ward8, 'data/clean/ward8.csv')
