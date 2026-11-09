## -----------------------------------------------------------------------------
#| label: setup
#| include: false
# R CMD build records its installation here. Quarto on Windows can lose the
# temporary library when starting its R subprocess (quarto-r issue #217).
build_library <- Sys.getenv("R_BUILD_TEMPLIB")
if (nzchar(build_library)) .libPaths(c(build_library, .libPaths()))


## -----------------------------------------------------------------------------
library(relm)
control <- rbind(c(2, 0, -1, 0.5), c(0, 3, 1, 2))
target <- control + rbind(c(1, 2, 0, 0), c(3, 0, 0, 0))
dimnames(target) <- dimnames(control) <- list(c("pair-a", "pair-b"), as.character(1:4))
hashes <- sprintf("%064x", 1:6)
context <- list(
  model = list(sha256 = strrep("a", 64), architecture = "synthetic",
    quantization = "synthetic", hidden_size = 4L, layers = 3L,
    engine_revision = "synthetic-example-v1"),
  capture = list(component = "residual", positions = "last",
    input_format = "raw_text", tokenizer = "gguf_embedded",
    add_special = TRUE, parse_special = FALSE, template_sha256 = NULL,
    context_length = 128L, backend = "cpu", relm_version = "0.3.0"),
  pairs = data.frame(pair_id = rownames(target),
    target_sha256 = hashes[1:2], control_sha256 = hashes[3:4],
    target_pos = c(3L, 5L), control_pos = c(4L, 6L)),
  splits = data.frame(prompt_sha256 = hashes,
    split = c(rep("construction", 4), "selection", "evaluation")),
  seed = NULL
)
direction <- llm_direction(target, control, context, layer = 2)
stopifnot(max(abs(direction$value - c(2, 1, 0, 0) / sqrt(5))) < 1e-12)
direction


## -----------------------------------------------------------------------------
#| fig-width: 10
#| fig-height: 7
barplot(direction$value, names.arg = direction$neuron,
  xlab = "Residual coordinate", ylab = "Unit-direction value",
  main = "Synthetic paired contrast: target minus control", col = "steelblue")
abline(h = 0)
attr(direction, "direction")$diagnostics$pairs


## -----------------------------------------------------------------------------
path <- tempfile(fileext = ".rds")
saveRDS(direction, path, version = 3)
restored <- readRDS(path)
stopifnot(identical(restored, direction))
print(restored) # validates the artifact before printing
unlink(path)


## -----------------------------------------------------------------------------
#| eval: false
# # m is the original handle created from the independently verified cached file.
# tr <- llm_trace(m, construction_prompt, layers = 12, positions = "last",
#                 components = "residual", spill = FALSE)
# stopifnot(identical(tr$neuron, seq_len(m$hidden_size)),
#           length(unique(tr$token_pos)) == 1L)
# values <- tr$value
# actual_source_position <- unique(tr$token_pos)
# rm(tr)
# # Repeat for the corresponding target/control prompt, storing one matrix row.


## -----------------------------------------------------------------------------
#| eval: false
# # destination_record was recorded independently for the actual loaded model.
# # It contains sha256, architecture, quantization, hidden_size, layers,
# # and engine_revision, exactly as construction context$model.
# changed <- llm_apply_direction(m, restored, destination_record, coef = 1)
# answer <- llm_generate(changed, held_out_prompt, temperature = 0, seed = 101)
# close(changed)


## -----------------------------------------------------------------------------
mlp_context <- context
mlp_context$capture$component <- "mlp_out"
mlp_direction <- llm_direction(target, control, mlp_context, layer = 2)
stopifnot(identical(attr(mlp_direction, "direction")$schema, "relm_direction/2"),
          identical(attr(direction, "direction")$schema, "relm_direction/1"))

# Unit direction v; a single synthetic component row h.
v <- mlp_direction$value
h <- c(3, 2, -1, 0.5)
project <- function(coef) h - coef * v * sum(v * h)
stopifnot(identical(project(0), h),
          max(abs(project(1) - c(-0.2, 0.4, -1, 0.5))) < 1e-12,
          abs(sum(v * project(1))) < 1e-12,
          abs(sum(v * project(-1)) - 2 * sum(v * h)) < 1e-12)
data.frame(neuron = 1:4, original = h, removed = project(1),
           amplified = project(-1))


## -----------------------------------------------------------------------------
#| eval: false
# # real_mlp_direction was built from actual full-width mlp_out observations.
# projected <- llm_apply_direction(m, real_mlp_direction, destination_record,
#   coef = 1, operator = "project", max_bytes = 64 * 1024^2)
# plot(projected, layers = c(1L, 12L, m$layers))
# answer <- llm_generate(projected, held_out_prompt, temperature = 0, seed = 101)
# close(projected)

