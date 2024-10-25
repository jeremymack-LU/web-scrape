# Packages ----
#install.packages('pacman')
pacman::p_load(tidyverse, rvest, xml2, googlesheets4)

# Scrape ----
# Paste together url string
{
  base_url <- 'https://www.teamrankings.com/nfl/matchup/' # Base url
  visiting <- 'ravens' # Visiting team
  home <- 'browns' # Home team
  week <- 8 # Week of schedule
  year <- 2024 # Calendar year
  
  url <- paste0(
    base_url, visiting,'-', home,'-week-', week,'-', year,'/efficiency'
  )
}

# Scrape html
html <- read_html(url)

# Read table elements
tables <- html |> 
  html_nodes("table") |> 
  html_table()

html  <- read_html("https://www.teamrankings.com/")
links <- html |>  
  html_nodes('a') |> 
  html_attr('href')

nfl_links <- links[grepl("nfl", links) & grepl("efficiency", links)]

table_scrape <- function(x){
  # Set base url
  base_url <- 'https://www.teamrankings.com'
  
  # Paste page specific url
  page_url <- paste0(base_url, x)
  
  # Read page html
  html <- read_html(page_url)
  
  # Read table elements
  tables <- html |> 
    html_nodes("table") |> 
    html_table()
  
  tables <- lapply(tables, function(df) {
    df %>% mutate_if(is.numeric, as.character)
  })
  
  # Combine tables into one
  table <- bind_rows(tables)
  
  # Add game
  game <- str_sub(page_url, 42, -24)
  
  # Add game to table
  table <- table |> 
    mutate(matchup = game) |> 
    relocate(matchup, .before = 'Stat') |> 
    rename(
      Away = 3,
      Home = 5
    )
}

# Map all games into a single data frame
all_stats <- map_dfr(nfl_links, table_scrape)

# Pass to Google ----
# Passing to Google is interactive and should open a web browser
# to ask for authentication and permission
ss <- gs4_create('teamrank_scrape')
sheet_write(all_stats, ss = ss, sheet = 'teamrank_scrape')
sheet_delete(ss, sheet = 'Sheet1')
