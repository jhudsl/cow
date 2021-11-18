#' Retrieve learning objectives for a chapter
#'
#' Given an repository on GitHub, retrieve all the bookdown chapter
#' information for the Github page if it exists.
#' Currently only public repositories are supported.
#'
#' @param repo_name The full name of the repo to get bookdown chapters from.
#' e.g. "jhudsl/DaSL_Course_Template_Bookdown"
#'
#' @return find learning objectives for a particular chapter
#'
#' @importFrom magrittr %>%
#' @import dplyr
#'
#' @export
#'
#' @examples
#'
#' get_learning_obj("https://jhudatascience.org/Documentation_and_Usability/what-does-good-documentation-look-like.html")
#'
get_learning_obj <- function(chapt_url) {

  # Try chapter url
  chapt_html <- suppressWarnings(try(xml2::read_html(paste(chapt_url, collapse = "\n"))))

  # Extract chapter nodes
  nodes <- rvest::html_nodes(chapt_html, xpath = paste0("//", 'img'))

  # Get alternative text
  fig_alts <- rvest::html_attr(nodes, "alt")

  # Get learning objectives from alternative text from images
  learning_objs <- grep("learning objective", fig_alts, ignore.case = TRUE, value = TRUE)

  learning_objs <-
}
