library(tidyverse)
library(patchwork)
library(camcorder)

plot_main <- penguins |> 
  drop_na(sex) |> 
  ggplot(aes(x = bill_len, y = body_mass, color = species)) +
  geom_point() +
  guides(color = "none") +
  labs(x = "Bill length (mm)", y = "Body mass (g)") +
  theme_bw()

plot_bars <- penguins |> 
  count(species) |> 
  ggplot(aes(x = species, y = n, fill = species)) + 
  geom_col() +
  guides(fill = "none") +
  labs(x = NULL, y = NULL) +
  theme_void() +
  theme(axis.text.x = element_text(face = "bold"))

gg_record(
  dir = file.path("recording"),
  device = "png",
  width = 6,
  height = 4,
  units = "in",
  dpi = 600
)


# Make all the plots

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.1, right = 0.5,\nbottom = 0.5, to = 0.9",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.1, right = 0.5, 
    bottom = 0.5, top = 0.9
  )

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.05, right = 0.35,\nbottom = 0.5, top = 0.99",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.05, right = 0.35, 
    bottom = 0.5, top = 0.9
  )

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.02, right = 0.35,\nbottom = 0.5, top = 0.9",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.02, right = 0.35, 
    bottom = 0.5, top = 0.9
  )

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.1, right = 0.5,\nbottom = 0.5, to = 0.9",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.02, right = 0.35, 
    bottom = 0.6, top = 0.95
  )

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.02, right = 0.35,\nbottom = 0.7, top = 0.97",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.02, right = 0.35, 
    bottom = 0.7, top = 0.97
  )

plot_main + 
  annotate(
    geom = "label", x = I(0.55), y = I(0.1), 
    label = "left = 0.02, right = 0.35,\nbottom = 0.65, top = 0.97",
    color = "red", hjust = 0, fill = "yellow",
    family = "Courier", fontface = "bold", size = 10, size.unit = "pt"
  ) +
  inset_element(
    plot_bars, 
    left = 0.02, right = 0.35, 
    bottom = 0.65, top = 0.97
  )

# This *should* work but it adds weird letterbox black bars to the top/bottom,
# and it results in a low 72 dpi resolution
# gg_playback(
#   name = file.path("recording", "inset-placement.gif"),
#   first_image_duration = 1,
#   last_image_duration = 3,
#   frame_duration = .4,
#   image_resize = 3600,
#   width = 3600, height = 2400,
#   last_as_first = FALSE
# )

# So instead I do it with {gifski} directly
png_files <- list.files("recording", pattern = "\\.png$", full.names = TRUE) |> 
  sort()

# Base frame duration
frame_duration <- 0.4

# Calculate repetitions for first and last frames
first_reps <- round(1 / frame_duration)
last_reps <- round(3 / frame_duration)

# Repeat first and last frames
png_files_expanded <- c(
  rep(png_files[1], first_reps),
  png_files[2:(length(png_files) - 1)],
  rep(png_files[length(png_files)], last_reps)
)

gifski(
  png_files_expanded,
  gif_file = file.path("recording", "inset-placement.gif"),
  delay = frame_duration,
  loop = TRUE,
  width = 3600,
  height = 2400
)
