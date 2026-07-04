# Public reproducibility setup

required_packages <- c("ggplot2", "dplyr", "tidyr", "readr", "scales", "grid")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Please install the following R packages before running this workflow: ",
    paste(missing_packages, collapse = ", ")
  )
}

library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(scales)
library(grid)

root_dir <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
if (basename(root_dir) == "code") {
  root_dir <- dirname(root_dir)
}
if (!dir.exists(file.path(root_dir, "data"))) {
  stop("Please run these scripts from the github folder or from github/code.")
}

data_dir <- file.path(root_dir, "data")
revise_data_dir <- file.path(data_dir, "revise")
output_dir <- file.path(root_dir, "output")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

read_public_csv <- function(...) {
  readr::read_csv(file.path(...), show_col_types = FALSE)
}

theme_public <- function(base_size = 12) {
  theme_classic(base_size = base_size) +
    theme(
      strip.background = element_rect(fill = "grey90", color = "grey45", linewidth = 0.5),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.4),
      panel.grid.minor = element_line(color = "grey94", linewidth = 0.25)
    )
}

save_public_plot <- function(plot, file_stub, width = 8, height = 6) {
  ggsave(
    filename = file.path(output_dir, paste0(file_stub, ".png")),
    plot = plot,
    width = width,
    height = height,
    dpi = 300,
    bg = "white"
  )
  ggsave(
    filename = file.path(output_dir, paste0(file_stub, ".pdf")),
    plot = plot,
    width = width,
    height = height,
    bg = "white"
  )
}

line_palette <- c(
  "True ERF" = "black",
  "Station-Daily" = "#FDB863",
  "Grid-Daily" = "#FDB863",
  "City-Daily" = "#1B9E77",
  "City-Weekly" = "#56B4E9",
  "City-Monthly" = "#CC79A7",
  "City-Monthly fitted" = "#CC79A7",
  "Monthly analytical estimand" = "#0072B2",
  "S2 formula-corrected" = "#009E73",
  "True generating ERF" = "black",
  "Monthly fitted ERF" = "#D55E00"
)
