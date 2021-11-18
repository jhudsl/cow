#' Retrieve bookdown chapters for a repository
#'
#' Given an repository on GitHub, retrieve all the bookdown chapter
#' information for the Github page if it exists.
#' Currently only public repositories are supported.
#'
#' @param org_name the name of the organization that e.g. "jhudsl"
#' @param url_base the base url of the github pages for this organization
#' e.g. "http://jhudatascience.org/"
#' @param output_file a file path for where the chapter information should be
#' saved e.g. "jhudsl_chapter.tsv"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' Authorization handled by [@get_git_auth]
#'
#' @return A TRUE/FALSE whether or not the repository exists. Optionally the
#' output from git ls-remote if return_repo = TRUE.
#'
#' @importFrom magrittr %>%
#' @import dplyr
#'
#' @export
#'
#' @examples
#'
#' get_chapters("jhudsl/DaSL_Course_Template_Bookdown")
#'
get_chapters <- function(repo_name, git_pat = NULL) {

  auth_arg <- get_git_auth(git_pat = git_pat)

  # Declare file name for this organization
  json_file <- paste0(gsub("/", "-", repo_name), ".json")

  # Download the repos and save to file
  curl_command <-
    paste0("curl ",
           auth_arg,
           " https://api.github.com/repos/",
           repo_name,
           "/pages",
           " > ",
           json_file)

  # Run the command
  system(curl_command)

  # Read in json file
  repo_info <- jsonlite::read_json(json_file)

  # Remove to clean up
  file.remove(json_file)

  message(paste0("Retrieving chapters from: ", repo_name))

  # Build github pages names
  gh_page <- paste0(repo_info$html_url, "/index.html")

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
