#' Retrieve information about a github repo
#'
#' Given an repository on GitHub, retrieve the information about it from the
#' GitHub API and read it into R.
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
#' repo_info <- get_repo_info("jhudsl/Documentation_and_Usability")
get_repo_info <- function(repo_name,
                          git_pat = NULL,
                          verbose = FALSE,
                          keep_json = FALSE) {
  repo_info <- NA

  # Build auth argument
  auth_arg <- get_git_auth(git_pat = git_pat)

  exists <- check_git_repo(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = FALSE,
    silent = TRUE
  )

  if (exists) {
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
        " > ",
        json_file
      )

    # Run the command
    system(curl_command)

    # Read in json file
    repo_info <- jsonlite::read_json(json_file)

    if (keep_json) {
      file.remove(json_file)
    }
  } else {
    warning(paste0(repo_name, " could not be found with the given credentials."))
  }
  return(repo_info)
}
