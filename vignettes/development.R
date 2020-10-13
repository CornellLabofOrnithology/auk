## ----print-filter, eval=FALSE-------------------------------------------------
#  # color filter
#  cat("  Feather color: ")
#  if (length(x$filters$color) == 0) {
#    cat("all")
#  } else {
#    cat(paste(x$filters$color, collapse = ", "))
#  }
#  cat("\n")

## ----awk-code, eval=FALSE-----------------------------------------------------
#    # color filter
#    if (length(filters$color) == 0) {
#      filter_strings$color <- ""
#    } else {
#      idx <- col_idx$index[col_idx$id == "color"]
#      condition <- paste0("$", idx, " == \"", filters$color, "\"",
#                          collapse = " || ")
#      filter_strings$color <- str_interp(awk_if, list(condition = condition))
#    }

## ----species-specific, eval=FALSE---------------------------------------------
#  s_filters <- x$filters
#  s_filters$species <- character()
#  ## ADD THIS LINE
#  s_filters$color <- character()
#  ##
#  awk_script_sampling <- awk_translate(filters = s_filters,
#                                       col_idx = x$col_idx_sampling,
#                                       sep = sep,
#                                       select = select_cols)

