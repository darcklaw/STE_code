# Formula-based post-hoc correction

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

correction_curves <- read_public_csv(revise_data_dir, "02_scenario2_monthly_s2_correction_curves.csv") %>%
  mutate(Curve = as.character(Curve))

lost_variance_hist <- read_public_csv(revise_data_dir, "02_scenario2_monthly_lost_variance_histogram_bins.csv")

correction_cities <- c("Barcelona", "Beijing", "Chiang Mai", "Rome")
correction_cities <- intersect(correction_cities, unique(correction_curves$City_Name))

correction_curves <- correction_curves %>%
  filter(City_Name %in% correction_cities, Curve %in% c("City-Monthly fitted", "S2 formula-corrected"))

lost_variance_hist <- lost_variance_hist %>%
  filter(City_Name %in% correction_cities)

p_correction_curves <- ggplot() +
  geom_rect(
    data = lost_variance_hist,
    aes(xmin = Temp_Bin_Left, xmax = Temp_Bin_Right, ymin = ymin, ymax = ymax),
    fill = "grey82",
    alpha = 0.55,
    color = NA
  ) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "grey55") +
  geom_line(
    data = correction_curves,
    aes(x = dose, y = RR, color = Curve, linetype = Curve),
    linewidth = 0.9,
    na.rm = TRUE
  ) +
  scale_color_manual(values = line_palette, breaks = intersect(names(line_palette), unique(correction_curves$Curve))) +
  labs(x = "Temperature (deg C)", y = "Relative risk", color = NULL, linetype = NULL) +
  facet_wrap(~ City_Name, scales = "free_x", ncol = 2) +
  coord_cartesian(ylim = c(0.76, 1.50)) +
  theme_public(12)

save_public_plot(p_correction_curves, "04_formula_based_correction_curves", width = 9, height = 7)

af_df <- read_public_csv(revise_data_dir, "02_scenario2_monthly_s2_correction_af.csv") %>%
  pivot_longer(
    cols = c(Heat_AF, Cold_AF, Total_AF),
    names_to = "AF_Type",
    values_to = "AF"
  ) %>%
  mutate(
    AF_Type = factor(AF_Type, levels = c("Heat_AF", "Cold_AF", "Total_AF")),
    Model = factor(Model, levels = c("True ERF", "City-Monthly fitted", "S2 formula-corrected"))
  )

p_af <- ggplot(af_df, aes(x = Model, y = AF, fill = Model)) +
  geom_violin(alpha = 0.35, color = NA, trim = FALSE) +
  geom_boxplot(width = 0.22, outlier.alpha = 0.08, color = "black") +
  facet_wrap(~ AF_Type, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = c("True ERF" = "grey55", "City-Monthly fitted" = "#CC79A7", "S2 formula-corrected" = "#009E73")) +
  labs(x = NULL, y = "Attributable fraction (%)", fill = NULL) +
  theme_public(12) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "none")

save_public_plot(p_af, "04_formula_based_correction_attributable_fraction", width = 10, height = 4.8)

af_summary <- af_df %>%
  group_by(AF_Type, Model) %>%
  summarise(
    Median = median(AF, na.rm = TRUE),
    Q25 = quantile(AF, 0.25, na.rm = TRUE),
    Q75 = quantile(AF, 0.75, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(af_summary, file.path(output_dir, "04_formula_based_correction_af_summary.csv"))
