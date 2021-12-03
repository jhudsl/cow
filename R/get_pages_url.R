#' Retrieve pages url for a repo
#'
#' Given an repository on GitHub, retrieve the pages URL for it.
#'
#' @param repo_name The full name of the repo to get bookdown chapters from.
#' e.g. "jhudsl/DaSL_Course_Template_Bookdown"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' Authorization handled by \link[gitHelpeR]{get_git_auth}
#' @param verbose TRUE/FALSE do you want more progress messages?
#' @param keep_json verbose TRUE/FALSE keep the json file locally?
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
#' release_info <- get_pages_url("jhudsl/DaSL_Course_Template_Bookdown")
get_pages_url <- function(repo_name,
                          git_pat = NULL,
                          verbose = FALSE,
                          keep_json = FALSE) {
  releases <- NA

  # Build auth argument
  auth_arg <- get_git_auth(git_pat = git_pat)

  exists <- check_git_repo(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = verbose
  )

  if (exists) {
    # Get repo info
    repo_info <- get_repo_info(
      repo_name = repo_name,
      git_pat = git_pat
    )

    # Declare URL
    url <- paste0("https://api.github.com/repos/", repo_name, "/pages")

    # Github api get
    response <- httr::GET(url,
                          httr::add_headers(Authorization = paste0("token ", auth_arg$password)),
                          httr::accept_json())

    if (httr::http_error(response)) {
      warning(paste0("url: ", url, " failed"))
    }

    # Get content as JSON
    page_info <- httr::content(response, as = "parsed")

  } else {
    warning(paste0(repo_name, " could not be found with the given credentials."))
  }
  return(page_info$html_url)
}
