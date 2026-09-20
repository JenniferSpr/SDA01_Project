# The Evolution of Global Football Power

## Authors

- Jennifer Spieser

- Qiu Xu

- Hsiang-Chi Wang

## Description

**The Evolution of Global Football Power** is an interactive data analysis project examining how the balance of power in international football has evolved across countries, confederations, and time.

Using historical Elo ratings for national football teams, the project analyzes long-term changes in team strength and places the 2026 FIFA World Cup within this broader historical context. The analysis explores whether traditional football powers continue to dominate, how the relative strength of confederations has evolved, and how the 2026 World Cup participants compare based on their historical trajectories.

The project combines exploratory data analysis, interactive visualizations, time-series clustering, and predictive modeling. It is developed in R using R Markdown and Shiny.

## Folder Structure

The project is organized as follows:

```         
.
├── README.md
├── main.Rmd
├── styles.css
│
├── images/
│   └── Banner.png
│
├── data/
│   ├── wc2026_qualifier_history.csv
│   ├── actual_stage.csv
│   ├── third_place_assignments_495.csv
│   ├── calendar_ko.csv
│   ├── elo_ratings.csv
│   ├── we_elo_ratings.csv
│   └── elo_ratings_wc2026.csv
│
└── scripts/
    ├── world_cup.prediction.Rmd
    ├── world_cup_descriptive.Rmd
    ├── world_cup_clustering.Rmd
    └── wolrd_cup_simulation.Rmd
```

### Main Files

- `main.Rmd` - Main R Markdown document used to run and display the complete interactive project.

- `README.md` - Provides an overview of the project, its structure, dependencies, and instructions for running it.

### `images/`

Contains images used in the report.

### `data/`

Contains the datasets used throughout the analysis, including historical Elo ratings, World Cup qualification information, tournament stages, and knockout-stage information.

### `scripts/`

Contains the R Markdown files for the different components of the project:

- `world_cup_descriptive.Rmd` - Descriptive and exploratory analysis of historical football power and Elo ratings.

- `world_cup_clustering.Rmd` - Time-series clustering analysis used to identify similarities in teams' historical Elo trajectories.

- `world_cup.prediction.Rmd` - Predictive analysis related to the 2026 FIFA World Cup.

- `wolrd_cup_simulation.Rmd` - Simulation of the 2026 FIFA World Cup.

## How to Run

1.  Clone or download the project repository.

2.  Open the project in RStudio.

3.  Install the required R packages listed below.

4.  Open `main.Rmd`.

5.  Run the document using **Run Document** in RStudio.

The application uses the Shiny runtime and therefore runs as an interactive R Markdown document.

## Required Packages

This project requires the following R packages:

- **Data manipulation:** `dplyr`, `tidyr`, `purrr`, `forcats`, `tidyverse`

- **Data visualization:** `ggplot2`, `ggrepel`, `paletteer`, `patchwork`, `plotly`, `scales`

- **Statistical analysis and modeling:** `broom`, `ranger`, `rsample`, `yardstick`

- **Time-series clustering:** `dtw`, `dtwclust`, `proxy`

- **Tables and interactive output:** `DT`, `gt`

- **Dates and project management:** `lubridate`, `here`

- **Reporting and application:** `knitr`, `rmarkdown`, `shiny`

All required packages can be installed by running the following command in R:

```         
install.packages(c(
  "broom", "dplyr", "DT", "dtw", "dtwclust", "forcats",
  "ggplot2", "ggrepel", "gt", "here", "knitr", "lubridate",
  "paletteer", "patchwork", "plotly", "proxy", "purrr",
  "ranger", "rmarkdown", "rsample", "scales", "shiny",
  "tidyr", "tidyverse", "yardstick"
))
```
