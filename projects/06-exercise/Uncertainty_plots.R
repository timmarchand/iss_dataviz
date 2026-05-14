# Set up ----
## Load packages and libraries ----
remotes::install_github("teunbrand/gghalves@compat_ggplot2_400")
pacman::p_load(tidyverse, gapminder, ggridges, gghalves)

## Create gapminder subset data ----
gapminder_2002 <- gapminder |> 
  filter(year == 2002)

## Create intervals data ----
gapminder_intervals <- gapminder_2002 |> 
  mutate(africa = 
           ifelse(continent == "Africa", 
                  "Africa", 
                  "Not Africa")) |> 
  mutate(age_buckets = 
           cut(lifeExp, 
               breaks = seq(30, 90, by = 5))) |> 
  group_by(africa, age_buckets) |> 
  summarize(total = n())


# Plots from Uncertainty Slides ----

## Pyramid histograms ----
pyramid <- ggplot(gapminder_intervals, 
       aes(y = age_buckets,
           x = ifelse(africa == "Africa", 
                      total, -total),
           fill = africa)) +
  geom_col(width = 1, color = "white")

pyramid

## Ridge plot ----
ridges <- ggplot(filter(gapminder_2002, 
              continent != "Oceania"),
       aes(x = lifeExp,
           fill = continent,
           y = continent)) +
  geom_density_ridges()

ridges

## gghalves ----
halves <- ggplot(filter(gapminder_2002, 
              continent != "Oceania"),
       aes(y = lifeExp,
           x = continent,
           color = continent)) +
  geom_half_boxplot(side = "l") +
  geom_half_point(side = "r")

halves

## Raincloud plot ----
raincloud <- ggplot(filter(gapminder_2002, 
              continent != "Oceania"),
       aes(y = lifeExp,
           x = continent,
           color = continent)) +
  geom_half_point(side = "l", size = 0.3) + 
  geom_half_boxplot(side = "l", width = 0.5, 
                    alpha = 0.3, nudge = 0.1) +
  geom_half_violin(aes(fill = continent), 
                   side = "r") +
  guides(fill = "none", color = "none") +
  coord_flip()  

raincloud

