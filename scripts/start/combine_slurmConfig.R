# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

# combine_slurmconfig takes two strings with SLURM parameters (e.g. "--qos=priority --time=03:30:00")
# and combines them into one string of SLURM parameters overwriting the parameters in "original"
# if they also exist in "update_with".

combine_slurmConfig <- function(original, update_with) {

  # trim whitespaces
  original <- trimws(toString(original))
  update_with <- trimws(toString(update_with))

  # remove double whitespaces
  original <- gsub("\\s+", " ", original)
  update_with <- gsub("\\s+", " ", update_with)

  # if user chose "direct" dont update any slurm commands
  if (update_with == "direct") return(update_with)

  # ignore original if it is "direct"
  if (original == "direct") original <- ""

  # put RHS strings into vector
  v_update_with <- gsub("--.*=(.*)", "\\1", unlist(strsplit(update_with,split=" ")))
  # name the vector using LHS strings
  names(v_update_with) <- gsub("--(.*)=.*", "\\1", unlist(strsplit(update_with,split=" ")))

  # put RHS strings into vector
  v_original <- gsub("--.*=(.*)", "\\1", unlist(strsplit(original, split = " ")))
  # name the vector using LHS strings
  names(v_original) <- gsub("--(.*)=.*", "\\1", unlist(strsplit(original, split = " ")))

  # remove elements from "original" that are existing in "update_with"
  v_original <- v_original[!names(v_original) %in% names(v_update_with)]

  combined <- c(v_update_with, v_original)
  combined <- ifelse(grepl("^--", combined), combined, paste0("--", names(combined), "=", combined))

  # concatenate SLURM command (insert "--" and "=")
  res <- paste(combined, collapse = " ")

  return(res)
}
