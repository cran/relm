## -----------------------------------------------------------------------------
#| eval: false
# library(relm)
# m <- llm("/path/to/your/model.gguf")
# chunks <- list()
# pending <- llm_generate(m, "Explain a confidence interval in two sentences.",
#   seed = 17, async = TRUE,
#   on_token = function(batch) {
#     chunks[[length(chunks) + 1L]] <<- batch
#     cat(paste0(batch$text[batch$event == "text"], collapse = ""))
#   })
# observed <- promises::then(pending, function(value) {
#   events <- do.call(rbind, chunks)
#   reconstructed <- paste0(events$text[events$event == "text"], collapse = "")
#   stopifnot(identical(reconstructed, unname(as.character(value))))
#   print(head(events[events$event == "token", c("token_pos", "token_id", "elapsed")]))
# }, function(error) {
#   message(conditionMessage(error))
# })


## -----------------------------------------------------------------------------
#| eval: false
# window <- NULL
# pending <- llm_generate(m, "Count from 1 to 100.", seed = 17, async = TRUE,
#   on_token = function(batch) {
#     tokens <- batch[batch$event == "token", , drop = FALSE]
#     if (!nrow(tokens)) return(invisible(NULL))
#     window <<- tail(rbind(window, tokens), 128L)
#     seconds <- diff(range(window$elapsed))
#     if (seconds > 0) {
#       message(round((nrow(window) - 1L) / seconds, 1), " tokens/s in this window")
#     }
#   })


## -----------------------------------------------------------------------------
#| eval: false
# con <- file("tokens.csv", open = "wb")
# pending <- llm_generate(m, "Explain bootstrap resampling.", seed = 17,
#   async = TRUE, on_token = con)
# observed <- promises::then(pending, function(value) {
#   close(con) # The caller opens and closes the connection.
#   print(value)
# }, function(error) {
#   close(con)
#   message(conditionMessage(error))
# })


## -----------------------------------------------------------------------------
#| eval: false
# events <- read.csv("tokens.csv", fileEncoding = "UTF-8", check.names = FALSE,
#   na.strings = character(),
#   colClasses = c("integer", "character", "integer", "integer", "integer",
#     "character", "numeric", "character", "logical"))

