library(tidyverse)
library(urbnthemes)

# set_urbn_defaults(style = "print")

ch_agegroups <- read_csv("data/clean/ch_agegroups.csv") %>%
  select(-contains("total"))

ch_agegroups$bg_tract = paste(ch_agegroups$block_group, ch_agegroups$tract)

ch_ag_bars <- ch_agegroups %>%
  filter(generation_cat == "21 and under") %>%
  ggplot(aes(fill = factor(age_group, levels = c("21","20","18to19","15to17","10to14","5to9","under5")), y = percentage, x = bg_tract)) +
  geom_bar(position = "fill", stat = "identity") 

ch_ag_bars <- ch_agegroups %>%
  ggplot(aes(fill = factor(age_group, y = percentage, x = bg_tract))) +
  geom_bar(position = "fill", stat = "identity") +
  facet_wrap(~ generation_cat)

pie_chart <- ch_agegroups %>%
  filter(bg_tract == "Block Group 2 Census Tract 73.04") %>%
  ggplot(aes(x = "", y = percentage, fill = age_group)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0)
