#' Extract entries from a list based on the name
#'
#' Given a list, extract items based on their name
#'
#' @param api_list a list (probably from the GitHub api)
#' @param entry_name the name of the entry to be extracted from the api list e.g. "html_url"
#' @param fixed TRUE/FALSE whether or not the exact string should be used.
#' FALSE would mean regex will be interpretted.
#'
#' @return a subset of api_list that only contains items with the entry_name string in the name.
#'
#' @export
#'
#' @examples
#'
#' repo_info <- get_repo_info("jhudsl/Documentation_and_Usability")
#'
#' extract_entries(repo_info, "release", fixed = TRUE)
extract_entries <- function(api_list,
                            entry_name,
                            fixed = TRUE) {
  list_names <- names(unlist(api_list))

  indices <- grep(entry_name, list_names, fixed = fixed)

  return(unlist(api_list)[indices])
}
