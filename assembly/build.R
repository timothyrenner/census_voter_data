# This script builds the dataset from the source files.
# This is the schema it builds:
# 
# | column               | description                                                  |
# | -------------------- | ------------------------------------------------------------ |
# | state                | The state.                                                   |
# | year                 | The year of the election.                                    |
# | voter_pct_of_total   | The percentage of the state's population who voted.          |
# | voter_pct_of_citizen | The percentage of the state's citizens who voted.            |
# | reg_pct_of_total     | The percentage of the state's population registered to vote. |
# | reg_pct_of_citizen   | The percentage of the state's citizens registered to vote.   |

# The raw data comes from the following tables:
# A-3 (Congressional year voter and registered voter data by state)
# A-5a (Presidential year voter data by state)
# A-5b (Presidential year registered voter data by state)
# from the US Census Bureau. See:
# http://www.census.gov/data/tables/time-series/demo/voting-and-registration/voting-historical-time-series.html
# for more details.

library(tidyverse)

# Read in the eligible voters for the congressional years.
congress.voters.raw <- read_csv('raw_data/congressional_voting_by_state.csv')

# Tidy up the eligible voters for the congressional election years.
congress.voters <- congress.voters.raw %>% 
  # Flatten out the years.
  gather('year','pct', -state) %>%
  # Split year and total/citizen.
  separate(year, c('year', 'type'), sep='_') %>%
  # Break total and citizen back into their own columns.
  spread(type, pct) %>%
  # Alias the citizen and total percentages.
  select(year,
         state,
         voter_pct_of_total=total,
         voter_pct_of_citizen=citizen)

congress.registration.raw <- 
  read_csv('raw_data/congressional_registration_by_state.csv')

# Tidy up the registered voters for the congressional election years.
congress.registration <- congress.registration.raw %>%
  # Flatten out the years.
  gather('year', 'pct', -state) %>%
  # Split the year and total/citizen.
  separate(year, c('year', 'type'), sep='_') %>%
  # Break total and citizen back into their own columns.
  spread(type, pct) %>%
  # Alias the citizen and total percentages.
  select(year,
         state,
         reg_pct_of_total=total,
         reg_pct_of_citizen=citizen)

# Join the voter data with the registration data.
congress <- congress.voters %>%
  inner_join(congress.registration, by=c("state", "year"))

president.voters.raw <- read_csv('raw_data/presidential_voting_by_state.csv')

# Tidy up the eligible voters for the presidential election years.
president.voters <- president.voters.raw %>%
  # Flatten out the years.
  gather('year', 'pct', -state) %>%
  # Split the year and total/citizen.
  separate(year, c('year', 'type'), sep='_') %>%
  # Break total and citizen back into their own columns.
  spread(type, pct) %>%
  # Alias the citizen and total percentages.
  select(year,
         state,
         voter_pct_of_total=total,
         voter_pct_of_citizen=citizen)

president.registration.raw <- 
  read_csv('raw_data/presidential_registration_by_state.csv')

# Tidy up the registered voters for the presidential election years.
president.registration <- president.registration.raw %>%
  # Flatten out the years.
  gather('year', 'pct', -state) %>%
  # Split the year and total/citizen.
  separate(year, c('year', 'type'), sep='_') %>%
  # Break total and citizen back into their own columns.
  spread(type, pct) %>%
  # Alias the citizen and total percentages.
  select(year,
         state,
         reg_pct_of_total=total,
         reg_pct_of_citizen=citizen)

# Join the voter data with the registration data.
president <- president.voters %>%
  inner_join(president.registration, by=c("state", "year"))

# Read in the state converter.
states <- read_csv('raw_data/state_abbreviations.csv')

# Now put it all together.
census.voters <- congress %>%
  # Union with the presidential years.
  union_all(president) %>%
  # Get the state abbreviations.
  inner_join(states, by=c("state")) %>%
  # Swap out the state name with the abbreviation.
  select(year,
         state=abbreviation,
         voter_pct_of_total,
         voter_pct_of_citizen,
         reg_pct_of_total,
         reg_pct_of_citizen) %>%
  # Scale the percentages to real not-units.
  mutate(voter_pct_of_total = voter_pct_of_total / 100,
         voter_pct_of_citizen = voter_pct_of_citizen / 100,
         reg_pct_of_total = reg_pct_of_total / 100,
         reg_pct_of_citizen = reg_pct_of_citizen / 100) %>%
  # Finally, sort by year and state.
  arrange(year, state)

write_csv(census.voters, '../census_voter_data.csv')