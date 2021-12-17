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
  
  # Try to get credentials other way 
  auth_arg <- get_git_auth(git_pat = git_pat)
  
  git_pat <- auth_arg$password
  if (is.null(git_pat)) {
    message("No credentials being used, only public repositories will be successful")
  }
  
  # Declare URL
  url <- paste0("https://api.github.com/orgs/", org_name, "/repos?per_page=1000000")

  if (is.null(auth_arg$password)){
    # Github api get without authorization
    response <- httr::GET(
      url,
      httr::accept_json()
    )
  } else {
    # Github api get
    response <- httr::GET(
      url,
      httr::add_headers(Authorization = paste0("token ", auth_arg$password)),
      httr::accept_json()
    )
  }

  if (httr::http_error(response)) {
    warning(paste0("url: ", url, " failed"))
  }

  # Get content as JSON
  repos <- httr::content(response, as = "parsed")

  # Collect repo names
  repo_names_index <- grep("^full_name$", names(unlist(repos)))
  repo_names <- unlist(repos)[repo_names_index]

  return(repo_names)
}
