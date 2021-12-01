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
#' release_info <- get_release_info("jhudsl/DaSL_Course_Template_Bookdown")
get_release_info <- function(repo_name,
                             git_pat = NULL,
                             verbose = TRUE,
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

    # Get release URL
    release_api <- gsub("{/id}", "", repo_info$releases_url,
      fixed = TRUE
    )

    # Declare file name for this organization
    json_file <- paste0(gsub("/", "-", repo_name), "-release.json")

    # Download the repos and save to file
    curl_command <-
      paste0(
        "curl ",
        # If we want curl to be quiet
        ifelse(verbose, "", " -s "),
        auth_arg,
        " ", release_api,
        " > ",
        json_file
      )

    # Run the command
    system(curl_command)

    # Read in json file
    release_info <- jsonlite::read_json(json_file)

    releases <- data.frame(
      tag_name = extract_entries(release_info, "tag_name"),
      tag_date = extract_entries(release_info, "created_at")
    ) %>%
      dplyr::mutate(tag_date = as.Date(tag_date))

    if (!keep_json) {
      file.remove(json_file)
    }
  } else {
    warning(paste0(repo_name, " could not be found with the given credentials."))
  }
  return(releases)
}
