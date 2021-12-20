#' Retrieve information about a github repo
#'
#' Given an repository on GitHub, retrieve the information about it from the
#' GitHub API and read it into R.
#'
#' @param repo_name The full name of the repo to get bookdown chapters from.
#' e.g. "jhudsl/OTTR_Template"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' Authorization handled by \link[cow]{get_git_auth}
#' @param verbose TRUE/FALSE do you want more progress messages?
#'
#' @return a data frame with the repository with the following columns:
#' data_level, data_path, chapt_name, url, repository name
#'
#' @importFrom httr GET
#' @importFrom httr accept_json
#' @importFrom httr authenticate
#' @importFrom gitcreds gitcreds_get
#' @import dplyr
#'
#' @export
#'
#' @examples
#'
#' repo_info <- get_repo_info("jhudsl/Documentation_and_Usability")
get_repo_info <- function(repo_name,
                          git_pat = NULL,
                          verbose = FALSE) {
  repo_info <- NA

  exists <- check_git_repo(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = FALSE,
    silent = TRUE
  )

  if (exists) {
    # Declare URL
    url <- paste0("https://api.github.com/repos/", repo_name)

    # Try to get credentials other way
    auth_arg <- get_git_auth(git_pat = git_pat)

    git_pat <- try(auth_arg$password, silent = TRUE)

    if (grepl("Error", git_pat[1])) {
      # Github api get without authorization
      response <- httr::GET(
        url,
        httr::accept_json()
      )
    } else {
      # Github api get
      response <- httr::GET(
        url,
        httr::add_headers(Authorization = paste0("token ", git_pat)),
        httr::accept_json()
      )
    }

    if (httr::http_error(response)) {
      warning(paste0("url: ", url, " failed"))
    }

    # Get content as JSON
    repo_info <- httr::content(response, as = "parsed")
  } else {
    warning(paste0(repo_name, " could not be found with the given credentials."))
  }
  return(repo_info)
}
