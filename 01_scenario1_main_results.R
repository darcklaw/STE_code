# Scenario 1 main results

if (!exists("data_dir")) {
  setup_file <- if (file.exists(file.path("code", "00_setup.R"))) file.path("code", "00_setup.R") else "00_setup.R"
  source(setup_file)
}

load(file.path(data_dir, "scenario1_results_by_scale.Rdata"))

scenario1_curves <- plot_data_ci %>%
  mutate(Model = as.character(Model))

p_scenario1_erf <- ggplot(scenario1_curves, aes(x = Percentile, y = RR, color = Model, linetype = Model)) +
  geom_ribbon(
    data = scenario1_curves %>% filter(!is.na(RR_low), !is.na(RR_high)),
    aes(x = Percentile, ymin = RR_low, ymax = RR_high, fill = Model),
    inherit.aes = FALSE,
    alpha = 0.12,
    color = NA
  ) +
  geom_line(linewidth = 0.9) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "grey55") +
  scale_color_manual(values = line_palette, breaks = intersect(names(line_palette), unique(scenario1_curves$Model))) +
  scale_fill_manual(values = line_palette, breaks = intersect(names(line_palette), unique(scenario1_curves$Model))) +
  labs(x = "Temperature percentile", y = "Relative risk", color = NULL, fill = NULL, linetype = NULL) +
  theme_public(12)

save_public_plot(p_scenario1_erf, "01_scenario1_erf_by_scale", width = 8.5, height = 6)

agreement_df <- read_public_csv(data_dir, "Fig3_Scenario1_obs_vs_theory_SummaryStats.csv") %>%
  mutate(
    Mean_Underest_Obs = as.numeric(Mean_Underest_Obs),
    Mean_Underest_Theo = as.numeric(Mean_Underest_Theo),
    Mean_Sigma2 = as.numeric(Mean_Sigma2)
  )

agreement_fit <- lm(Mean_Underest_Obs ~ Mean_Underest_Theo, data = agreement_df)
agreement_label <- sprintf(
  "Linear fit: y = %.2f x %+0.1f pp\nR² = %.2f; dashed line = 1:1 identity",
  unname(coef(agreement_fit)[2]),
  100 * unname(coef(agreement_fit)[1]),
  summary(agreement_fit)$r.squared
)

p_scenario1_agreement <- ggplot(
  agreement_df,
  aes(x = Mean_Underest_Theo, y = Mean_Underest_Obs, color = Mean_Sigma2)
) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey55") +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.7) +
  geom_point(size = 3) +
  annotate("label", x = Inf, y = Inf, label = agreement_label, hjust = 1.03, vjust = 1.2, size = 3.4) +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_color_viridis_c(name = expression("Lost variance, " * sigma^2), option = "plasma") +
  labs(
    x = "Second-order Taylor prediction of underestimation",
    y = "Observed underestimation"
  ) +
  theme_public(12) +
  theme(legend.position = c(0.78, 0.22))

save_public_plot(p_scenario1_agreement, "01_scenario1_observed_vs_theoretical_underestimation", width = 7.2, height = 5.8)

write_csv(
  tibble(
    n = nrow(agreement_df),
    r_squared = summary(agreement_fit)$r.squared,
    intercept = unname(coef(agreement_fit)[1]),
    slope = unname(coef(agreement_fit)[2])
  ),
  file.path(output_dir, "01_scenario1_agreement_fit.csv")
)
