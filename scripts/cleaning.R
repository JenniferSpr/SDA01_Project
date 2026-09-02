# Library
library(here)

# Load data
d.raw <- read.csv(here("data", "elo_ratings_wc2026.csv"))

# Missing values 
colSums(is.na(d.raw))

# Duplicate values
sum(duplicated(d.raw))
sum(duplicated(d.raw[c("year", "country")]))

# Date range
range(d.raw$year)                      
range(d.raw$snapshot_date) 

# Check number of matches and goals
all(d.raw$matches_total == d.raw$matches_home + d.raw$matches_away + d.raw$matches_neutral)
all(d.raw$matches_total == d.raw$wins + d.raw$losses + d.raw$draws)

# Extract midyear snapshot date
d.wc <- d.raw[d.raw$year == 2026 & d.raw$snapshot_date == "2026-07-07", ]
d.full <- d.raw[!(d.raw$year == 2026 & d.raw$snapshot_date == "2026-07-07"), ]

# Check the duplicate values again
sum(duplicated(d.full[c("year", "country")])) 

# Save into new datasets
write.csv(d.wc, "data/wc_elo_ratings.csv", row.names = FALSE)
write.csv(d.full, "data/elo_ratings.csv", row.names = FALSE)

