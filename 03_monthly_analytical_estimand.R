# Monthly analytical estimand

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

estimand_curves <- read_public_csv(revise_data_dir, "01_scenario2_monthly_analytical_estimand_curves.csv") %>%
  mutate(Curve = as.character(Curve))

estimand_points <- read_public_csv(revise_data_dir, "01_scenario2_monthly_analytical_estimand_points.csv")

temperature_hist <- read_public_csv(revise_data_dir, "01_scenario2_monthly_temperature_histogram_bins.csv")

selected_cities <- c("Bangkok", "Beijing", "London", "Tokyo")
selected_cities <- intersect(selected_cities, unique(estimand_curves$City_Name))

estimand_curves <- estimand_curves %>%
  filter(City_Name %in% selected_cities)

estimand_points <- estimand_points %>%
  filter(City_Name %in% selected_cities)

temperature_hist <- temperature_hist %>%
  filter(City_Name %in% selected_cities)

p_estimand <- ggplot() +
  geom_rect(
    data = temperature_hist,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = "grey82",
    alpha = 0.55,
    color = NA
  ) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "grey55") +
  geom_line(
    data = estimand_curves,
    aes(x = dose, y = RR, color = Curve, linetype = Curve),
    linewidth = 0.9,
    na.rm = TRUE
  ) +
  geom_point(
    data = estimand_points,
    aes(x = Monthly_Temp_Mean, y = Analytical_RR),
    color = "#56B4E9",
    alpha = 0.6,
    size = 1.3
  ) +
  scale_color_manual(values = line_palette, breaks = intersect(names(line_palette), unique(estimand_curves$Curve))) +
  labs(x = "Temperature (deg C)", y = "Relative risk", color = NULL, linetype = NULL) +
  facet_wrap(~ City_Name, scales = "free_x", ncol = 2) +
  coord_cartesian(ylim = c(0.76, 1.55)) +
  theme_public(12)

save_public_plot(p_estimand, "03_monthly_analytical_estimand", width = 9, height = 7)
