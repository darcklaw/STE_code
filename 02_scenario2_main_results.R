# Scenario 2 representative city curves

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

scenario2_curves <- read_public_csv(data_dir, "Fig2_Scenario2_City_Represent_SummaryStats.csv") %>%
  mutate(Temporal_Scale = as.character(Temporal_Scale))

monthly_hist <- read_public_csv(data_dir, "Fig2_Scenario2_City_Represent_MonthlyTempHistogram.csv")

scenario2_curves <- scenario2_curves %>%
  left_join(
    monthly_hist %>%
      group_by(City_Name) %>%
      summarise(Monthly_T_Min = min(xmin), Monthly_T_Max = max(xmax), .groups = "drop"),
    by = "City_Name",
    suffix = c("", "_support")
  ) %>%
  mutate(
    RR_est = if_else(
      Temporal_Scale == "City-Monthly" &
        (dose < Monthly_T_Min_support | dose > Monthly_T_Max_support),
      NA_real_,
      RR_est
    )
  )

p_scenario2 <- ggplot() +
  geom_rect(
    data = monthly_hist,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = "grey82",
    alpha = 0.55,
    color = NA
  ) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "grey55") +
  geom_line(
    data = scenario2_curves,
    aes(x = dose, y = RR_est, color = Temporal_Scale, linetype = Temporal_Scale),
    linewidth = 0.8,
    na.rm = TRUE
  ) +
  scale_color_manual(values = line_palette, breaks = intersect(names(line_palette), unique(scenario2_curves$Temporal_Scale))) +
  labs(x = "Temperature (deg C)", y = "Relative risk", color = NULL, linetype = NULL) +
  facet_wrap(~ City_Name, scales = "free_x", ncol = 2) +
  coord_cartesian(ylim = c(0.75, 1.55)) +
  theme_public(12)

save_public_plot(p_scenario2, "02_scenario2_representative_city_curves", width = 9, height = 7)
