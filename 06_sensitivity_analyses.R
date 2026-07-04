# Minimal sensitivity analyses

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

sensitivity_curves <- read_public_csv(revise_data_dir, "04_minimal_sensitivity_curves.csv") %>%
  mutate(Curve = as.character(Curve))

sensitivity_summary <- read_public_csv(revise_data_dir, "04_minimal_sensitivity_summary.csv")

p_sensitivity_curves <- ggplot(
  sensitivity_curves,
  aes(x = Percentile, y = RR, color = Curve, linetype = Curve)
) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "grey55") +
  geom_line(linewidth = 0.85) +
  facet_wrap(~ Scenario, ncol = 2) +
  scale_color_manual(values = line_palette, breaks = intersect(names(line_palette), unique(sensitivity_curves$Curve))) +
  labs(x = "Temperature percentile", y = "Relative risk", color = NULL, linetype = NULL) +
  theme_public(11)

save_public_plot(p_sensitivity_curves, "06_sensitivity_curves", width = 9, height = 10)
write_csv(sensitivity_summary, file.path(output_dir, "06_sensitivity_summary.csv"))

variance_summary <- read_public_csv(revise_data_dir, "04_variance_injection_summary.csv")

p_variance_extension <- ggplot(
  variance_summary,
  aes(
    x = Mean_Delta_Theory,
    y = Mean_Delta_Exact,
    color = factor(Variance_Multiplier),
    size = Mean_Sigma2
  )
) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey55") +
  geom_point(alpha = 0.88) +
  scale_color_viridis_d(name = "Variance multiplier", option = "plasma") +
  scale_size_continuous(name = expression("Lost variance, " * sigma^2), range = c(1.5, 5)) +
  labs(
    x = "Second-order Taylor delta on logRR scale",
    y = "Exact analytical delta on logRR scale"
  ) +
  theme_public(12) +
  theme(legend.position = "right")

save_public_plot(p_variance_extension, "06_large_variance_extension", width = 8, height = 6)

write_csv(variance_summary, file.path(output_dir, "06_large_variance_extension_summary.csv"))
