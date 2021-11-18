#' Retrieve all bookdown chapters for an org
#'
#' Given an organization on GitHub, retrieve all the bookdown chapter
#' information for all the Github pages that exist for all the repositories.
#' Currently only public repositories are supported.
#'
#' @param org_name the name of the organization that e.g. "jhudsl"
#' @param output_file a file path for where the chapter information should be
#' saved e.g. "jhudsl_repos.tsv"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' @param verbose TRUE/FALSE do you want more progress messages?
#'
#' @return A TRUE/FALSE whether or not the repository exists. Optionally the
#' output from git ls-remote if return_repo = TRUE.
#'
#' @export
#'
#' @examples
#'
#' retrieve_org_repos(
#'   org_name = "jhudsl",
#'   output_file = "jhudsl_repos.tsv"
#' )
retrieve_org_repos <- function(org_name = NULL,
                               output_file = "org_repos.tsv",
                               git_pat = NULL,
                               verbose = TRUE) {
  # Build auth argument
  auth_arg <- get_git_auth(git_pat = git_pat)

  # Declare file name for this organization
  json_file <- paste0(org_name, "-repos.json")

  # Download the repos and save to file
  curl_command <-
    paste0(
      "curl ",
      # If we want curl to be quiet
      ifelse(verbose, "", " -s "),
      auth_arg,
      " https://api.github.com/orgs/",
      org_name,
      "/repos?per_page=1000000 > ",
      json_file
    )

  # Run the command
  system(curl_command)

  # Read in json file
  repos <- jsonlite::read_json(json_file)

  # Collect repo names
  repo_names_index <- grep("^full_name$", names(unlist(repos)))
  repo_names <- unlist(repos)[repo_names_index]

  return(repo_names)
}
