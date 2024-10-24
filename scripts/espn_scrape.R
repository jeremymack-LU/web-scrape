# Packages ----
#install.packages('pacman')
pacman::p_load(tidyverse, rvest, xml2, googlesheets4)

# Scrape 1 ----
# Scrape ESPN table data after inspecting in browser and copying
# the xpath for each table
url <- 'https://www.espn.com/college-football/fpi'
xpath1 <- '//*[@id="fittPageContainer"]/div[2]/div[2]/div/div/section/div/div[4]/div/div/table'
xpath2 <- '//*[@id="fittPageContainer"]/div[2]/div[2]/div/div/section/div/div[4]/div/div/div/div[2]/table'

table_p1 <- url |> 
  read_html() |> 
  html_nodes(xpath=xpath1) |> 
  html_table()

table_p2 <- url |> 
  read_html() |> 
  html_nodes(xpath=xpath2) |> 
  html_table()

table <- table_p1 |> 
  bind_cols(table_p2)

# Pass to Google ----
# Passing to Google is interactive and should open a web browser
# to ask for authentication and permission
ss <- gs4_create('espn_scrape')
sheet_write(table, ss = ss, sheet = 'espn_table_method1')
sheet_delete(ss, sheet = 'Sheet1')

# Scrape 2 ----
# Scrape ESPN table by grabbing table elements from html
html <- read_html("https://www.espn.com/college-football/fpi")
tables <- html |> 
  html_nodes("table") |> 
  html_table()

table <- bind_cols(tables)

# Pass to Google ----
sheet_write(table, ss = ss, sheet = 'espn_table_method2')
