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
#' @return a data frame with the repository's release information: tag_name and tag_date.
#' NAs are returned in these columns if there are no releases.
#'
#' @importFrom magrittr %>%
#' @import dplyr
#'
#' @export
#'
#' @examples \dontrun{
#'
#' release_info <- get_release_info("jhudsl/OTTR_Template")
#' }
get_release_info <- function(repo_name,
                             git_pat = NULL,
                             verbose = TRUE) {
  releases <- NA

  # Get repo info
  repo_info <- get_repo_info(
    repo_name = repo_name,
    git_pat = git_pat
  )

  # Declare URL
  url <- gsub("{/id}", "", repo_info$releases_url,
    fixed = TRUE
  )

  # Try to get credentials other way
  auth_arg <- get_git_auth(git_pat = git_pat, quiet = TRUE)

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
  release_info <- httr::content(response, as = "parsed")

  if (length(release_info) == 0) {
    if (verbose) {
      message(paste0("No releases for ", repo_name))
    }
    # If there is no releases, put an NA
    releases <- data.frame(
      tag_name = NA,
      tag_date = NA
    )
  } else {
    # If there are releases, get the tag name and date
    releases <- data.frame(
      tag_name = extract_entries(release_info, "tag_name"),
      tag_date = extract_entries(release_info, "created_at")
    ) %>%
      dplyr::mutate(tag_date = as.Date(tag_date))
  }
  return(releases)
}
