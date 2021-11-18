#' Handle GitHub PAT authorization
#'
#' Handle things whether or not a GitHub PAT is supplied.
#'
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#'
#' @return Authorization argument to supply to curl OR a blank string if no
#' authorization is found or supplied.
#'
#' @export
#'
get_git_auth <- function(git_pat = NULL) {
  if (is.null(git_pat)) {
    git_pat <- gitcreds::gitcreds_get()$password
    if (is.null(git_pat)) {
      warning("No github credentials found or provided.
              Only public repositories will be retrieved. Set GitHub token using
              usethis::create_github_token()
              if you would like private repos to be included.")
    }
  }

  if (!is.null(git_pat)) {
    auth_arg <- paste0("-H 'Authorization: token ", git_pat, "'")
  } else {
    auth_arg <- ""
  }
  return(auth_arg)
}
