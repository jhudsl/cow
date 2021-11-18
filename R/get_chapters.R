utils::globalVariables(c(
  "data_path"
  ))


#' Retrieve bookdown chapters for a repository
#'
#' Given an repository on GitHub, retrieve all the bookdown chapter
#' information for the Github page if it exists.
#' Currently only public repositories are supported.
#'
#' @param repo_name The full name of the repo to get bookdown chapters from.
#' e.g. "jhudsl/DaSL_Course_Template_Bookdown"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' Authorization handled by \link[gitHelpeR]{get_git_auth}
#' @param retrieve_learning_obj TRUE/FALSE attempt to retrieve learning objectives?
#' @param verbose TRUE/FALSE do you want more progress messages?
#'
#' @return a data frame with the repository with the following columns:
#' data_level, data_path, chapt_name, url, repository name
#'
#' @importFrom magrittr %>%
#' @import dplyr
#'
#' @export
#'
#' @examples
#'
#' get_chapters("jhudsl/Documentation_and_Usability")
get_chapters <- function(repo_name,
                         git_pat = NULL,
                         retrieve_learning_obj = FALSE,
                         verbose = TRUE) {

  # Build auth argument
  auth_arg <- get_git_auth(git_pat = git_pat)

  # Declare file name for this organization
  json_file <- paste0(gsub("/", "-", repo_name), ".json")

  # Download the repos and save to file
  curl_command <-
    paste0(
      "curl ",
      # If we want curl to be quiet
      ifelse(verbose, "", " -s "),
      auth_arg,
      " https://api.github.com/repos/",
      repo_name,
      "/pages",
      " > ",
      json_file
    )

  # Run the command
  system(curl_command)

  # Read in json file
  repo_info <- jsonlite::read_json(json_file)

  # Remove to clean up
  file.remove(json_file)

  chapt_data <- data.frame(
    data_level = NA,
    data_path = NA,
    chapt_name = NA,
    url = NA,
    course = repo_name
  )

  if (retrieve_learning_obj) {
    chapt_data$learning_obj <- NA
  }

  if (!is.null(repo_info$html_url)) {
    message(paste0("Retrieving chapters from: ", repo_name))

    # Build github pages names
    gh_page <- paste0(repo_info$html_url, "index.html")

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
          dplyr::mutate(
            chapt_name = rvest::html_text(nodes),
            url = paste0(repo_info$html_url, data_path),
            course = repo_name
          ) %>%
          dplyr::select(-class) %>%
          as.data.frame()

        if (retrieve_learning_obj) {
          chapt_data$learning_obj <- lapply(chapt_data$url, get_learning_obj)
        }
      }
    }
  }
  return(chapt_data)
}
