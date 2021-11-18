#' Retrieve all bookdown chapters
#'
#' Given an organization on GitHub, retrieve all the bookdown chapter
#' information for all the Github pages that exist for all the repositories.
#' Currently only public repositories are supported.
#'
#' @param org_name the name of the organization that e.g. "jhudsl"
#' @param url_base the base url of the github pages for this organization
#' e.g. "http://jhudatascience.org/"
#' @param output_file a file path for where the chapter information should be
#' saved e.g. "jhudsl_chapter.tsv"
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
#' retrieve_org_chapters(
#'   org_name = "jhudsl",
#'   output_file = "jhudsl_chapter_info.tsv"
#' )
retrieve_org_chapters <- function(org_name = NULL,
                                  url_base = NULL,
                                  output_file = "org_chapter_info.tsv",
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

  all_chapters <- lapply(repo_names,
    get_chapters,
    git_pat = git_pat
  )

 names(all_chapters) <- repo_names

 all_chapters_df <- all_chapters %>%
   dplyr::bind_rows(.id = "repo") %>%
   readr::write_tsv(file.path(output_file))

  return(all_chapters_df)
}
