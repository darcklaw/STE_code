# Agreement metrics and Bland-Altman diagnostics

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

ba_df <- read_public_csv(revise_data_dir, "03_obs_vs_theory_bland_altman_data.csv")
metrics_df <- read_public_csv(revise_data_dir, "03_obs_vs_theory_agreement_metrics.csv")

mean_diff <- metrics_df$bland_altman_mean_diff[1]
lower_loa <- metrics_df$bland_altman_lower_loa[1]
upper_loa <- metrics_df$bland_altman_upper_loa[1]

p_ba <- ggplot(ba_df, aes(x = BA_Mean, y = BA_Diff, color = Mean_Sigma2)) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "grey55") +
  geom_hline(yintercept = mean_diff, color = "#0072B2", linewidth = 0.8) +
  geom_hline(yintercept = c(lower_loa, upper_loa), linetype = "dashed", color = "grey45") +
  geom_point(size = 3) +
  annotate(
    "text",
    x = Inf,
    y = -Inf,
    hjust = 1.02,
    vjust = -0.5,
    label = sprintf(
      "Mean difference = %.3f; 95%% limits of agreement = [%.3f, %.3f]",
      mean_diff,
      lower_loa,
      upper_loa
    ),
    size = 3.4
  ) +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_color_viridis_c(
    name = expression("Lost variance, " * sigma^2),
    option = "plasma",
    breaks = c(100, 150, 200, 300)
  ) +
  labs(
    x = "Mean of observed and predicted underestimation",
    y = "Observed - predicted underestimation"
  ) +
  theme_public(12) +
  theme(legend.position = c(0.82, 0.30))

save_public_plot(p_ba, "05_bland_altman_underestimation", width = 8.5, height = 6)

write_csv(metrics_df, file.path(output_dir, "05_agreement_metrics.csv"))
