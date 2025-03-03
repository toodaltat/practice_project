################################################################################
source("03_modeling.R")
################################################################################
# LDA plots
################################################################################

plot_skills <- lda_skills %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("Skills") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    strip.text = element_text(size = 14),
    panel.spacing = unit(1, "lines")  # Add spacing between facets
  )


plot_skills_required <- lda_skills_required %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("Skills Required") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    strip.text = element_text(size = 14),
    panel.spacing = unit(1, "lines")
  )


plot_field_studied <- lda_field_studied %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("Field Studied") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    strip.text = element_text(size = 14),
    panel.spacing = unit(1, "lines")
  )


plot_career <- lda_career %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("Career") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    strip.text = element_text(size = 14),
    panel.spacing = unit(1, "lines")
  )


plot_responsibilites <- lda_responsibilites %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("Responsibilities") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 14),
    strip.text = element_text(size = 14),
    panel.spacing = unit(1, "lines")
  )

# Combine plots into a grid layout
combined_plot <- (plot_skills | plot_skills_required)

################################################################################
# Save the plots
################################################################################
ggsave(paste0(plot_folder_path, "plot_skills.png"), plot = plot_skills, width = 14, height = 10, dpi = 300)
ggsave(paste0(plot_folder_path, "plot_skills_required.png"), plot = plot_skills_required, width = 14, height = 10, dpi = 300)
ggsave(paste0(plot_folder_path, "plot_field_studied.png"), plot = plot_field_studied, width = 14, height = 10, dpi = 300)
ggsave(paste0(plot_folder_path, "plot_career.png"), plot = plot_career, width = 14, height = 10, dpi = 300)
ggsave(paste0(plot_folder_path, "plot_responsibilites.png"), plot = plot_responsibilites, width = 14, height = 10, dpi = 300)

ggsave(paste0(plot_folder_path, "plot_skills_compare.png"), plot = combined_plot, width = 14, height = 10, dpi = 300)

