

get_chapters <- function(repo_name, url_base = url_base) {
  message(paste0("Retrieving chapters from: ", repo_name))

  # Build github pages names
  gh_page <- paste0(url_base, repo_name, "/index.html")

  # Read in html
  index_html <- suppressWarnings(try(xml2::read_html(paste(gh_page, collapse = "\n"))))

  if (!grepl("HTTP error 404.", index_html[1])) {
    # Extract chapter nodes
    nodes <- rvest::html_nodes(index_html, xpath = paste0("//", 'li[@class="chapter"]'))

    if (length(nodes) > 0) {
      # Format into a data.frame
      chapt_data <- rvest::html_attrs(nodes) %>%
        dplyr::bind_rows() %>%
        dplyr::rename_with(~ gsub("-", "_", .x, fixed = TRUE)) %>%
        dplyr::mutate(chapt_names = rvest::html_text(nodes),
                      url = paste0(gh_page, "/", data_path),
                     course = repo_name) %>%
        dplyr::select(-class)

      return(chapt_data)
    }
  } else {
    warning(paste0("No chapters found at ", gh_page))
  }
}
