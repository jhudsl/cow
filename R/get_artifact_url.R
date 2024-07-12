#' Get artifact file URL
#'
#' If you have a GitHub actions that uploads an artifact file, this function can
#' retrieve the URL for you to use to download that file.
#'
#' @param artifact_name The job name of the artifact to be retrieved, for example "spell-check-results"
#' document of the chapter in the repository you are retrieving it from that
#' you would like to include in the current document. e.g "docs/intro.md" or "intro.md"
#' @param repo_name A character vector indicating the repo name of where you are
#'  borrowing from. e.g. "jhudsl/OTTR_Template/".
#' For a Wiki of a repo, use "wiki/jhudsl/OTTR_Template/"
#' If nothing is provided, will look for local file.
#' @param git_pat A personal access token from GitHub. Only necessary if the
#' repository being checked is a private repository.
#'
#' @return A download url for the most recent run that matches the artifact name.
#'
#' @export
#'
#' @examples \dontrun{
#'
#' # If in GitHub actions you have something like this:
#'
#' #     - name: Archive spelling errors
#' #       uses: actions/upload-artifact\@v2
#' #       with:
#' #         name: spell-check-results
#' #         path: spell_check_results.tsv
#'
#' # This you can run this:
#'
#' githubr::get_artifact_url(
#'   artifact_name = "spell-check-results",
#'   repo_name = "jhudsl/OTTR_Template",
#'   git_pat = "gh_12345"
#' )
#' }
#'
get_artifact_url <- function(artifact_name,
                             repo_name = NULL,
                             git_pat = NULL) {
  exists <- check_git_repo(
    repo_name = repo_name,
    git_pat = git_pat,
    verbose = FALSE,
    silent = TRUE
  )

  if (exists) {
    # Declare URL
    url <- paste0("https://api.github.com/repos/", repo_name, "/actions/artifacts")

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
    artifacts <- httr::content(response, as = "parsed")$artifacts

    if (length(artifacts) < 1) {
      warning("No results")
    }

    # Make it a data frame
    artifacts_df <- do.call(rbind.data.frame, as.list(artifacts))

    # We only care about the spell check results and the most recent one
    artifact_url <- artifacts_df %>%
      dplyr::filter(name == artifact_name) %>%
      dplyr::top_n(1, created_at) %>%
      dplyr::pull(archive_download_url)

    # Github api get the location of the artifact
    response <- httr::GET(
      artifact_url,
      httr::add_headers(Authorization = paste0("token ", git_pat))
    )

    # Print out download url
    return(response$url)
  } else {
    warning(paste0(repo_name, " could not be found with the given credentials."))
  }
}
