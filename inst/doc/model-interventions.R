## -----------------------------------------------------------------------------
#| label: setup
#| include: false
# R CMD build records its installation here. Quarto on Windows can lose the
# temporary library when starting its R subprocess (quarto-r issue #217).
build_library <- Sys.getenv("R_BUILD_TEMPLIB")
if (nzchar(build_library)) .libPaths(c(build_library, .libPaths()))


## -----------------------------------------------------------------------------
#| fig-width: 10
#| fig-height: 7
library(relm)
source(system.file("examples", "graphics-states.R", package = "relm"), local = TRUE)
comparison <- llm_compare(reference, intervention, context, layer = 2)
stopifnot(identical(comparison$difference, c(0.5, -1, 1, 0)))
plot(comparison, main = "Synthetic observed-state comparison")


## -----------------------------------------------------------------------------
#| fig-width: 10
#| fig-height: 7
history <- llm_timeline(reference, max_states = 4)
for (i in 2:6) {
  state <- example_state(as.integer(i), coefficient = 0,
                         revision = 1L, after = 1L)
  history <- llm_timeline(state, history, max_states = 4)
}
plot(history, main = "Synthetic applied steering; truncated window")
history[, c("state_id", "coef", "applied_after_state", "effective_source_pos")]


## -----------------------------------------------------------------------------
#| eval: false
# m <- llm("/path/to/model.gguf", backend = "cpu", context_length = 512)
# changed <- llm_steer(m, layer = 2L, direction = direction, coef = 0.5)
# plot(changed, layers = c(1:4, 12))
# 
# settings <- list(seed = 17, chat = FALSE, temperature = 0, top_p = 0.95,
#   max_tokens = 32L, stop = NULL, context_length = 512L, backend = "cpu",
#   relm_version = as.character(packageVersion("relm")),
#   engine_revision = "your recorded build revision")
# 
# # Run sequentially, waiting for each promise before starting the next model job.
# # Save only the selected state's activations, all sampled IDs (<= 1024),
# # and a bounded audit table. Keep callbacks short.
# run <- function(model, prompt) {
#   result <- new.env(parent = emptyenv())
#   result$ids <- integer(); result$state <- NULL; result$history <- NULL
#   result$promise <- llm_generate(model, prompt, chat = settings$chat,
#     max_tokens = settings$max_tokens, seed = settings$seed,
#     temperature = settings$temperature, top_p = settings$top_p,
#     stop = settings$stop, async = TRUE, layers = 2L, top = 5L,
#     on_state = function(state) {
#       result$ids <- c(result$ids, state$step$token_id)
#       result$history <- llm_timeline(state, result$history, max_states = 32L)
#       if (state$step$state_id == 1L) {
#         result$state <- state
#         result$prefix <- result$ids
#       }
#       NULL  # history is data, not a steering reply
#     })
#   result
# }


## -----------------------------------------------------------------------------
#| eval: false
# record <- function(run) list(model_sha256 = recorded_sha256,
#   settings = settings, generated_tokens = run$prefix)
# paired <- llm_compare(baseline$state, treated$state,
#   context = list(reference = record(baseline), intervention = record(treated)),
#   layer = 2L)
# plot(paired)
# plot(treated$history)
# close(changed); close(m)


## -----------------------------------------------------------------------------
#| eval: false
# pdf("comparison.pdf", width = 10, height = 7)
# tryCatch(plot(paired), finally = dev.off())
# write.csv(as.data.frame(paired), "comparison.csv", row.names = FALSE)
# saveRDS(paired, "comparison-with-provenance.rds")

