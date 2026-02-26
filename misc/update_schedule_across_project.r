## Collect all current dates ----
library(tidyverse)
library(yaml)

# Folders to scan
folders <- c("lesson", "assignment", "content", "example")

# Function to extract YAML fields from a qmd file
extract_yaml <- function(filepath, type) {
  lines <- read_lines(filepath)
  
  # Find YAML block (between --- delimiters)
  delimiters <- which(lines == "---")
  if (length(delimiters) < 2) return(NULL)
  
  yaml_block <- lines[(delimiters[1] + 1):(delimiters[2] - 1)]
  meta <- tryCatch(yaml.load(paste(yaml_block, collapse = "\n")), error = function(e) NULL)
  if (is.null(meta)) return(NULL)
  
  tibble(
    file     = filepath,
    type     = type,
    title    = meta$title %||% NA_character_,
    date     = meta$date %||% NA_character_,
    date_end = meta$date_end %||% NA_character_
  )
}

# Scan all folders
dates_df <- map_dfr(folders, function(folder) {
  qmds <- list.files(folder, pattern = "\\.qmd$", full.names = TRUE)
  map_dfr(qmds, extract_yaml, type = folder)
}) |>
  arrange(type, file)

View(dates_df)

## Match dates to new schedule ----
library(tidyverse)
library(yaml)

# Read schedule
schedule <- read_csv("data/schedule.csv") |>
  mutate(session_num = str_pad(row_number(), 2, pad = "0"))  # "01", "02", etc.

# Folders and the schedule columns that map to them
folder_map <- tribble(
  ~folder,      ~date_col,    ~date_end_col,
  "lesson",     "date",       "end_date",
  "content",    "date",       "end_date",
  "example",    "date",       "end_date",
  "assignment", "date",       NA_character_
)

# Function to update YAML date fields in a single qmd file
update_dates <- function(filepath, new_date, new_date_end = NULL) {
  lines <- read_lines(filepath)
  
  # Update date
  if (!is.na(new_date)) {
    lines <- str_replace(lines, '^date:.*$', paste0('date: "', new_date, '"'))
  }
  
  # Update date_end if present in file and new value provided
  if (!is.null(new_date_end) && !is.na(new_date_end)) {
    if (any(str_detect(lines, "^date_end:"))) {
      lines <- str_replace(lines, '^date_end:.*$', paste0('date_end: "', new_date_end, '"'))
    }
  }
  
  write_lines(lines, filepath)
  message("Updated: ", filepath)
}

# Loop through folders
walk(seq_len(nrow(folder_map)), function(i) {
  folder      <- folder_map$folder[i]
  date_col    <- folder_map$date_col[i]
  date_end_col <- folder_map$date_end_col[i]
  
  walk(seq_len(nrow(schedule)), function(j) {
    session_num  <- schedule$session_num[j]
    new_date     <- schedule[[date_col]][j]
    new_date_end <- if (!is.na(date_end_col)) schedule[[date_end_col]][j] else NULL
    
    # Match files like 01-lesson.qmd, 01-exercise.qmd, 01-example.qmd etc.
    pattern  <- paste0("^", session_num, "-.*\\.qmd$")
    files    <- list.files(folder, pattern = pattern, full.names = TRUE)
    
    if (length(files) == 0) return()
    
    walk(files, update_dates, 
         new_date = new_date, 
         new_date_end = new_date_end)
  })
})

message("Done!")
