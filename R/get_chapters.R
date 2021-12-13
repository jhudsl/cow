utils::globalVariables(c(
  "data_path", "tag_date", "token", "freq", "keyword"
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
#' Authorization handled by \link[cow]{get_git_auth}
#' @param retrieve_learning_obj TRUE/FALSE attempt to retrieve learning objectives?
#' @param retrieve_keywords TRUE/FALSE attempt to retrieve keywords from the chapter?
#' @param udmodel A udmodel passed in for keyword determination. Will be obtained using
#' `udpipe::udpipe_download_model(language = "english")` if its not given.
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
                         retrieve_keywords = TRUE,
                         verbose = TRUE,
                         udmodel = NULL) {

  # Get repo info
  repo_info <- get_repo_info(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = verbose
  )

  # Get github pages url
  pages_url <- get_pages_url(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = FALSE
  )

  # Create space holder data.frame
  chapt_data <- data.frame(
    data_level = NA,
    data_path = NA,
    chapt_name = NA,
    url = NA,
    released = NA,
    course = repo_name,
    release = NA,
    release_date = NA
  )

  if (retrieve_learning_obj) {
    chapt_data$learning_obj <- NA
  }

  if (!is.na(pages_url)) {
    message(paste0("Retrieving info from: ", repo_name))

    # Build github pages names
    gh_page <- paste0(pages_url, "index.html")

    # Get release info
    release_info <- get_release_info(
      repo_name = repo_name,
      git_pat = git_pat,
      verbose = FALSE
    )

    if (!is.na(release_info$tag_name[1])) {
      # Get the most recent release
      release_info <- release_info %>%
        dplyr::arrange(tag_date)

      release_info <- release_info[1, ]
    }

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
            chapt_name = stringr::word(rvest::html_text(nodes), sep = "\n", 1),
            url = paste0(pages_url, data_path),
            course = repo_name,
            release = release_info$tag_name,
            release_date = release_info$tag_date
          ) %>%
          dplyr::select(-class) %>%
          as.data.frame()

        # Get unique urls
        unique_urls <- unique(chapt_data$url)

        if (retrieve_learning_obj) {

          # Only run learning objectives for each unique url
          learning_obj_key <- sapply(unique_urls, get_learning_obj)

          # Match up the url to the found learning objectives
          chapt_data <- chapt_data %>%
            dplyr::mutate(learning_obj = dplyr::recode(url, !!!learning_obj_key))
        }

        if (retrieve_keywords) {

          # Set up model if its not provided
          if (is.null(udmodel)) {
            udmodel <- udpipe::udpipe_download_model(language = "english")
            udmodel <- udpipe::udpipe_load_model(file = udmodel$file_model)
          }
          # Only run keywords for each unique url
          keywords_key <- sapply(unique_urls, get_keywords, udmodel = udmodel)

          # Match up the url to the found learning objectives
          chapt_data <- chapt_data %>%
            dplyr::mutate(keywords = dplyr::recode(url, !!!keywords_key))
        }
      }
    }
  }
  return(chapt_data)
}
