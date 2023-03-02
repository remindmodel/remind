#!/usr/bin/env Rscript

# Cascade REMIND scenarios in config files.

cascade_scenarios <- function(file = NULL, cascade = NULL) {
    help_text <- 'Cascade REMIND scenarios inside scenario configuration file.
Usage: `cascade_scenarios(file, cascade)`
  `file`:    path to a REMIND scenario config .csv file
  `cascade`: list of scenario depenencies equal in form to
               list(\'SSP2EU-Base\' = \'SSP2EU-NDC\',
                    \'SSP2EU-NDC\'  = \'SSP2EU-NPi\',
                    \'SSP2EU-NPi\'  = c(\'SSP2EU-PkBudg1150\',
                                      \'SSP2EU-PkBudg500\'))
`file` will be changed, so ensure version control first.  Also, check results
manually before using them.
'

    if (any(is.null(file), is.null(cascade))) {
        cat(help_text)
        return(invisible())
    }

    require(tidyverse)

    lines <- read_lines(file = file)
    non_comment_lines <- which(!grepl('^[[:blank:]]*#', lines))

    df <- read_delim(
        file = paste(lines[non_comment_lines], collapse = '\n'),
        delim = ';',
        col_types = cols(.default = col_character()),
        na = character(),
        show_col_types = FALSE)

    result <- tibble()
    for (i in seq_along(cascade)) {
        raw_scenarios <- df %>%
            filter(.data$title %in% cascade[[i]])

        if ('copyConfigFrom' %in% colnames(raw_scenarios)) {
            raw_scenarios <- raw_scenarios %>%
                filter(.data$copyConfigFrom == '')
        }

        cooked_scenarios <- left_join(
            x = raw_scenarios %>%
                pivot_longer(-'title'),

            y = df %>%
                filter(names(cascade[i]) == .data$title) %>%
                pivot_longer(-'title') %>%
                select(-'title', base = 'value'),

            by = 'name', multiple = 'all'
        ) %>%
            mutate(
                value = ifelse(.data$value == .data$base, '', .data$value)) %>%
            select(-'base') %>%
            pivot_wider() %>%
            mutate(copyConfigFrom = names(cascade[i]))

        result <- bind_rows(result, cooked_scenarios)
    }

    result <- left_join(
        df %>%
            select('title'),

        bind_rows(
            df %>%  anti_join(result, 'title'),
            result),

        'title'
    ) %>%
        select(all_of(unique(c('title', 'start', 'copyConfigFrom',
                               colnames(df))))) %>%
        replace_na(list(copyConfigFrom = '')) %>%
        pivot_longer(-'title') %>%
        mutate(value = ifelse(grepl(';', .data$value),
                              paste0('"', .data$value, '"'),
                              .data$value)) %>%
        pivot_wider()

    for (i in seq_along(non_comment_lines)) {
        if (1 == i) {
            text <- colnames(result)
        } else {
            text <- result[i-1,]
        }

        lines[non_comment_lines[i]] <- paste(text, collapse = ';')
    }

    write_lines(lines, file)
}

if (0 == sys.nframe()) {
    cascade_scenarios()
}
