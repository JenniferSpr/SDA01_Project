# Library
library(here)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(shiny)
library(DT)
library(paletteer)
library(patchwork)
library(forcats)
library(broom)
library(purrr)


# Load Data
d.full <- read.csv(here("data", "elo_ratings.csv"))
d.wc = read.csv(here("data", "wc_elo_ratings.csv"))

# Overview of data ----

## Summary table ----
# Summary table for cumulative number of qualified from 1901 - 2026, 
# rating, ranking, and win rate (cumulative) by country
t.summary = d.full %>% 
  group_by(country) %>%
  mutate(win_pct = round(wins/matches_total*100, 2)) %>%
  summarise(n_qualified = n(),
            mean_rating = rating_avg[which.max(year)],
            min_rating = rating_min[which.max(year)],
            max_rating = rating_max[which.max(year)],
            min_ranking = rank_min[which.max(year)],
            max_ranking = rank_max[which.max(year)],
            win_percent = win_pct[which.max(year)])

## Elo rating of top 10 countries (current rating) ----
# Extract top 10 country names 
top10_current = d.full %>%
  group_by(country) %>%
  filter(year == max(year)) %>%
  ungroup() %>%
  slice_max(rating, n = 10) %>%
  pull(country)

# Filter full data based on the top 10 names
d.top10 = d.full %>%
  filter(country %in% top10_current) %>%
  mutate(country = factor(country, levels = top10_current))

# [FIGURE] Bar chart: current rating by country
ggplot(d.top10[d.top10$year == 2026,], 
       aes(x = reorder(country, -rating), y = rating)) +
  geom_col(fill = "#1D9E75") +
  geom_text(aes(label = rating), vjust = -0.5, size = 3.5) +
  labs(
    title = "Top 10 Teams by Current Elo Rating (2026)",
    x = NULL, y = "Elo Rating"
  ) +
  coord_cartesian(ylim = c(1900, 2200)) +
  theme_minimal() 

## Elo rating trajectory of top 10 countries ----
# [FIGURE] Line chart
top10_palette <- c(
  "#8B3A3A", "#A3B18A", "#8FA6B3", "#C9A66B", "#A995A8",
  "#A79E93", "#B0A89D", "#B9B2A7", "#C2BBB1", "#CBC5BB"   # ranks 6-10
)

top10_linewidth <- seq(1.0, 0.5, length.out = 10)
top10_alpha     <- seq(1.0, 0.2, length.out = 10)

# Looping i from 10 down to 1 means rank 10's layer is added FIRST (drawn at
# the back) and rank 1's layer is added LAST (drawn on top of everything).
line_layers <- lapply(10:1, function(i) {
  geom_line(
    data = d.top10 %>% filter(country == top10_current[i]),
    aes(x = year, y = rating),
    color = top10_palette[i],
    linewidth = top10_linewidth[i],
    alpha = top10_alpha[i]
  )
})

ggplot(d.top10, aes(x = year, y = rating, color = country)) +
  line_layers + 
  geom_line(linewidth = 0) + 
  labs(
    title = 'Elo Rating Trajectory - Top 10 Teams (by 2026 rating)',
    x = NULL, y = NULL, color = NULL
  ) +
  scale_color_manual(values = top10_palette, breaks = top10_current) +
  scale_linewidth_manual(values = top10_linewidth) +
  scale_alpha_manual(values = top10_alpha) +
  guides(color = guide_legend(override.aes = list(linewidth = 2, alpha = 1))) +
  scale_x_continuous(limits = c(1901, 2026), 
                     breaks = c(seq(1901, 2021, by = 10), 2026)) +
  scale_y_continuous(limits = c(1200, 2300),
                     breaks = seq(1200, 2400, by = 200)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


## Elo rating of Confederation over time ----
d.cf = d.full %>%
  group_by(year, confederation) %>%
  summarise(avg_rating = mean(rating))

ggplot(d.cf, aes(x = year, y = avg_rating, color = confederation)) +
  geom_line(linewidth = 1, alpha = 0.8) +
  labs(title = "Average Elo Rating by Confederation",
       x = NULL, y = NULL, color = NULL) +
  scale_color_paletteer_d("ggthemes::Classic_10") +
  scale_x_continuous(limits = c(1901, 2026), 
                     breaks = c(seq(1901, 2021, by = 10), 2026)) +
  scale_y_continuous(limits = c(1100, 2000),
                     breaks = seq(1100, 2000, by = 100)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


## Gap between max and current rating ----
# [FIGURE] Lollipop chart
# Extract the data
d.gap = d.full %>%
  group_by(country) %>%
  filter(year == 2026) %>%
  ungroup() %>%
  mutate(rating_gap = rating - rating_max,
         country = fct_reorder(country, rating)) %>%
  select(year, country, rating, rating_max, rating_gap)

# Figure settins
n_teams = nlevels(d.gap$country)

legend_y = n_teams + 1
legend_x_current = mean(range(d.gap$rating, d.gap$rating_max)) - 60
legend_x_max     = mean(range(d.gap$rating, d.gap$rating_max)) + 60

p_main = ggplot(d.gap, aes(y = country)) +
  geom_segment(aes(x = rating, xend = rating_max, yend = country),
               color = "#E7E7E7", linewidth = 3.5) +
  geom_point(aes(x = rating), color = "#436685", size = 3) +
  geom_point(aes(x = rating_max), color = "#BF2F24", size = 3) +
  geom_text(aes(x = rating, label = rating),
            hjust = 1.4, size = 3, color = "#436685") +
  geom_text(aes(x = rating_max, label = rating_max),
            hjust = -0.4, size = 3, color = "#BF2F24") +
  # legend dots — own single-row data, independent of the main 48-row dataset
  geom_point(data = data.frame(x = legend_x_current - 25, y = legend_y),
             aes(x = x, y = y), color = "#436685", size = 3, inherit.aes = FALSE) +
  geom_point(data = data.frame(x = legend_x_max - 25, y = legend_y),
             aes(x = x, y = y), color = "#BF2F24", size = 3, inherit.aes = FALSE) +
  # legend text
  annotate("text", x = legend_x_current, y = legend_y, label = "Current",
           color = "#436685", fontface = "bold", size = 3.25, hjust = 0) +
  annotate("text", x = legend_x_max, y = legend_y, label = "All-time max",
           color = "#BF2F24", fontface = "bold", size = 3.25, hjust = 0) +
  scale_x_continuous(expand = expansion(mult = c(0.08, 0.08))) +
  labs(x = "Elo rating", y = NULL) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_text(color = "black")
  ) +
  coord_cartesian(ylim = c(1, n_teams + 1.5))

# Gap column — same reserved header space, same y-range
p_gap = ggplot(d.gap, aes(y = country, x = 0)) +
  geom_text(aes(label = paste0(rating_gap)), fontface = "bold", size = 3.25,
            color = "#BF2F24") +
  annotate("text", x = 0, y = n_teams + 1, label = "Diff",
           fontface = "bold", size = 3.75, color = "black") +
  theme_void() +
  coord_cartesian(xlim = c(-0.05, 0.05),
                  ylim = c(1, n_teams + 1.5)) +  # must match p_main exactly
  theme(plot.margin = margin(l = 0, r = 10, t = 0, b = 0),
        panel.background = element_rect(fill = "#EFEFE3", color = "#EFEFE3"))

# Combine, then add the figure title ABOVE both panels equally
(p_main + p_gap + plot_layout(widths = c(5, 1))) +
  plot_annotation(
    title = "Current vs. All-Time Max Elo Rating",
    #subtitle = "National teams, 2026",
    theme = theme(plot.title = element_text(face = "bold", size = 14),
                  plot.subtitle = element_text(color = "grey40", size = 10))
  )


## Home advantage vs. win rate ----
d.home = d.full %>%
  group_by(country) %>%
  filter(year == 2026) %>%
  ungroup() %>%
  mutate(home_share = matches_home / matches_total,
         win_rate = wins / matches_total)

# correlation of two variables
corr = cor(d.home$home_share, d.home$win_rate)

ggplot(d.home, aes(x = home_share, y = win_rate)) +
  geom_smooth(method = "lm", se = FALSE, color = "black",
              linetype = "dashed", linewidth = 0.8) +
  geom_point(aes(color = rating), size = 3, alpha = 0.85) +
  scale_color_distiller(palette = "Spectral", name = "Current\nElo Rating") +
  # label a few notable teams
  ggrepel::geom_text_repel(
    data = d.home %>% filter(country %in% c("Brazil","Spain","England","France",
                                             "Iraq","United States",
                                            "South Africa", "Ecuador")),
    aes(label = country), size = 3
  ) +
  labs(
    title = "Home Advantage vs. Win Rate",
    subtitle = paste0("Correlation (r) = ", round(corr, 2)),
    x = "Share of matches played at home",
    y = "Win rate"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

## Host country effect on elo ratings ----
# Add host country information from 1930 - 2022
host_events <- tribble(
  ~year, ~country,
  1930, "Uruguay",
  1938, "France",
  1950, "Brazil",
  1954, "Switzerland",
  1958, "Sweden",
  1966, "England",
  1970, "Mexico",
  1974, "Germany",
  1978, "Argentina",
  1982, "Spain",
  1986, "Mexico",
  1994, "United States",
  1998, "France",
  2002, "South Korea",
  2002, "Japan",
  2006, "Germany",
  2010, "South Africa",
  2014, "Brazil",
  2022, "Qatar"
)

# For each host event, compute:
#    pre_avg      = mean rating over the 3 years before hosting
#    host_rating  = rating in the host year
#    post_rating  = rating 1 year after hosting
get_host_stats <- function(host_year, host_country) {
  sub <- d.full %>% filter(country == host_country)
  
  pre_years <- seq(host_year - 3, host_year - 1)
  pre_avg <- sub %>% filter(year %in% pre_years) %>% summarise(m = mean(rating)) %>% pull(m)
  
  host_rating <- sub %>% filter(year == host_year) %>% pull(rating)
  post_rating <- sub %>% filter(year == host_year + 1) %>% pull(rating)
  
  if (length(host_rating) == 0 || length(post_rating) == 0 || is.nan(pre_avg)) {
    return(NULL)
  }
  
  tibble(
    country = host_country,
    year = host_year,
    pre_avg = pre_avg,
    host_rating = host_rating,
    post_rating = post_rating
  )
}

host_stats <- map2(host_events$year, host_events$country, get_host_stats) %>%
  list_rbind() %>%
  mutate(
    label = paste(country, year),
    bump_during = host_rating - pre_avg,      # host year vs pre-host baseline
    reversion   = post_rating - host_rating,  # post-year vs host year
    net_after   = post_rating - pre_avg       # post-year vs pre-host baseline
  ) %>%
  arrange(bump_during)

print(host_stats)

# Paired t-tests
# (a) Pre-host baseline vs host year -> is there a bump?
t_pre_vs_host <- t.test(host_stats$host_rating, host_stats$pre_avg, 
                        paired = TRUE)

# (b) Host year vs post-host year -> does the bump revert?
t_host_vs_post <- t.test(host_stats$post_rating, host_stats$host_rating, 
                         paired = TRUE)

# (c) Nonparametric checks (Wilcoxon signed-rank), since n = 19 is small
w_pre_vs_host  <- wilcox.test(host_stats$host_rating, host_stats$pre_avg, 
                              paired = TRUE)
w_host_vs_post <- wilcox.test(host_stats$post_rating, host_stats$host_rating, 
                              paired = TRUE)

ttest_table <- bind_rows(
  tidy(t_pre_vs_host)  %>% 
    mutate(comparison = "Host year vs. pre-host (3yr avg)", 
           test = "Paired t-test"),
  tidy(t_host_vs_post) %>% 
    mutate(comparison = "Post-host (1yr) vs. host year",     
           test = "Paired t-test")
) %>%
  select(comparison, test, estimate, statistic, p.value, parameter, 
         conf.low, conf.high) %>%
  rename(
    mean_diff = estimate,
    t_stat = statistic,
    df = parameter,
    ci_low = conf.low,
    ci_high = conf.high
  )

wilcoxon_table <- tibble(
  comparison = c("Host year vs. pre-host (3yr avg)", "Post-host (1yr) vs. host year"),
  test = "Wilcoxon signed-rank",
  V_stat = c(w_pre_vs_host$statistic, w_host_vs_post$statistic),
  p.value = c(w_pre_vs_host$p.value, w_host_vs_post$p.value)
)

print(ttest_table)
print(wilcoxon_table)


# Descriptive summary alongside the tests
summary_table <- host_stats %>%
  summarise(
    n = n(),
    mean_bump_during   = mean(bump_during),
    median_bump_during = median(bump_during),
    pct_positive_bump  = mean(bump_during > 0) * 100,
    mean_reversion      = mean(reversion),
    mean_net_after       = mean(net_after)
  )
print(summary_table)

# [Figure] Chart of pre-host/host year/post-host year Elo ratings
plot_data <- host_stats %>%
  select(label, year, bump_during, pre_avg, host_rating, post_rating) %>%
  pivot_longer(
    cols = c(pre_avg, host_rating, post_rating),
    names_to = "stage",
    values_to = "rating"
  ) %>%
  mutate(
    stage = factor(stage,
                   levels = c("pre_avg", "host_rating", "post_rating"),
                   labels = c("3yr pre-host avg", "Host year", "1 year after")),
    label = fct_reorder(label, year)  # sort rows by size of the bump
  )

host_bump_plot <- ggplot(plot_data, aes(x = rating, y = label)) +
  geom_line(aes(group = label), color = "grey70", linewidth = 0.6) +
  geom_point(aes(color = stage), size = 3) +
  scale_color_manual(values = c(
    "3yr pre-host avg" = "#888780",
    "Host year"         = "#1D9E75",
    "1 year after"      = "#D85A30"
  )) +
  labs(
    title = "Elo rating before, during, and after hosting the World Cup",
    subtitle = "19 historical hosts, sorted by size of the host-year bump",
    x = "Elo rating",
    y = NULL,
    color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.y = element_blank(),
    legend.position = "top"
  )

print(host_bump_plot)


## Elo trajectory: debutant/returning teams vs traditional qualifiers ----
# Groups: 
#   (Source: https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_qualification)
# - Debutants (first qualified in 2026): Cape Verde, Curacao, Jordan,
#     and Uzbekistan
# - Returners: total time of qualified = 2 & current consecutive appearances = 1
#     [Haiti, DR Congo, Iraq, Panama, Bosnia and Herzegovina]
# - Traditional power: total time of qualified >= 10 & current consecutive
#     appearances >= 2 
#     [Brazil, Germany, Argentina, Mexico, England, France, Spain, Uruguay, 
#      Belgium, Switzerland, Netherlands, South Korea, United States]
# - Occasional qualifier: everything else
 
# Read qualification data
qualifiers <- read_csv(here("data", "wc2026_qualifier_history.csv"))

# Merge to d.full
d.full <- d.full %>%
  left_join(qualifiers %>% select(country, qualifier_category), by = "country")

# Calculate average Elo rating by qualification category
elo_by_group <- d.full %>%
  filter(!is.na(qualifier_category)) %>%
  group_by(qualifier_category, year) %>%
  summarise(avg_rating = mean(rating, na.rm = TRUE), .groups = "drop")

# Plotting
group_labels <- c(
  debutant          = "Debutant",
  long_gap_returner = "Long-gap returner",
  occasional        = "Occasional qualifier",
  traditional       = "Traditional power"
)

group_colors <- c(
  debutant          = "#2a78d6",
  long_gap_returner = "#eb6834",
  occasional        = "#1baf7a",
  traditional       = "#6250d6"
)

p <- ggplot(elo_by_group, aes(x = year, y = avg_rating,
                              color = qualifier_category,
                              linetype = qualifier_category)) +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = group_colors, labels = group_labels, name = NULL) +
  scale_linetype_manual(
    values = c(debutant = "solid", long_gap_returner = "solid",
               occasional = "solid", traditional = "solid"),
    labels = group_labels, name = NULL
  ) +
  scale_x_continuous(limits = c(1901, 2026), 
                     breaks = c(seq(1901, 2021, by = 10), 2026)) +
  labs(
    title = "Average Elo rating by qualifier group, 1901-2026",
    x = "Year",
    y = "Average Elo rating"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

p


