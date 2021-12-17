#' Retrieve all bookdown chapters for an org
#'
#' Given an organization on GitHub, retrieve all the bookdown chapter
#' information for all the Github pages that exist for all the repositories.
#' Currently only public repositories are supported.
#'
#' @param org_name the name of the organization that e.g. "jhudsl"
#' @param output_file a file path for where the chapter information should be
#' saved e.g. "jhudsl_chapter.tsv"
#' @param git_pat If private repositories are to be retrieved, a github personal
#' access token needs to be supplied. If none is supplied, then this will attempt to
#' grab from a git pat set in the environment with usethis::create_github_token().
#' @param retrieve_learning_obj TRUE/FALSE attempt to retrieve learning objectives?
#' @param retrieve_keywords TRUE/FALSE attempt to retrieve keywords from the chapter?
#' @param verbose TRUE/FALSE do you want more progress messages?
#'
#' @return A TRUE/FALSE whether or not the repository exists. Optionally the
#' output from git ls-remote if return_repo = TRUE.
#'
#' @export
#'
#' @examples \dontrun{
#' retrieve_org_chapters(
#'   org_name = "jhudsl",
#'   output_file = "jhudsl_chapter_info.tsv"
#' )
#' }
retrieve_org_chapters <- function(org_name = NULL,
                                  output_file = "org_chapter_info.tsv",
                                  git_pat = NULL,
                                  retrieve_learning_obj = FALSE,
                                  retrieve_keywords = TRUE,
                                  verbose = TRUE) {

  # Retrieve all the repos for an org
  repo_names <- retrieve_org_repos(
    org_name = org_name,
    git_pat = git_pat,
    verbose = TRUE
  )

  # If retrieve keywords is true, set up the model
  if (retrieve_keywords) {
    udmodel <- udpipe::udpipe_download_model(language = "english")
    udmodel <- udpipe::udpipe_load_model(file = udmodel$file_model)
  }

  # Retrieve all the chapters
  all_chapters <- lapply(repo_names,
    get_chapters,
    git_pat = git_pat,
    retrieve_learning_obj = retrieve_learning_obj,
    retrieve_keywords = retrieve_keywords,
    udmodel = udmodel
  )

  # Put the names on this list
  names(all_chapters) <- repo_names

  # Get all the chapters for all these repos
  all_chapters_df <- all_chapters %>%
    dplyr::bind_rows(.id = "repo") %>%
    readr::write_tsv(file.path(output_file))

  return(all_chapters_df)
}
