#' Borrow/link a chapter from another bookdown course
#'
#' @param doc_path A file path of markdown or R Markdown
#' document of the chapter in the repository you are retrieving it from that
#' you would like to include in the current document. e.g "docs/intro.md" or "intro.md"
#' @param repo_name A character vector indicating the repo name of where you are
#'  borrowing from. e.g. "jhudsl/OTTR_Template/".
#' For a Wiki of a repo, use "wiki/jhudsl/OTTR_Template/"
#' If nothing is provided, will look for local file.
#' @param branch Default is to pull from main branch, but need to declare if other branch is needed.
#' @param git_pat A personal access token from GitHub. Only necessary if the
#' repository being checked is a private repository.
#' @param base_url it's assumed this is coming from github so it is by default 'https://raw.githubusercontent.com/'
#' @param dest_dir A file path where the file should be stored upon arrival to
#' the current repository.
#'
#' @return An Rmarkdown or markdown is knitted into the document from another repository
#'
#' @importFrom knitr opts_knit
#' @importFrom knitr knit_child
#' @importFrom knitr current_input
#' @importFrom utils download.file
#' @importFrom rprojroot find_root
#' @export
#'
#' @examples \dontrun{
#'
#' # In an Rmarkdown document:
#'
#' # For a file in another repository:
#' # ```{r, echo=FALSE, results='asis'}
#' borrow_chapter(
#'   doc_path = "docs/02-chapter_of_course.md",
#'   repo_name = "jhudsl/OTTR_Template"
#' )
#' # ```
#'
#' # For a local file:
#' # ```{r, echo=FALSE, results='asis'}
#' borrow_chapter(doc_path = "02-chapter_of_course.Rmd")
#' # ```
#' }
borrow_chapter <- function(doc_path,
                           repo_name = NULL,
                           branch = "main",
                           git_pat = NULL,
                           base_url = "https://raw.githubusercontent.com",
                           dest_dir = file.path("resources", "other_chapters")) {
  
  
  # Declare file names
  doc_path <- file.path(doc_path)
  doc_name <- basename(doc_path)
  
  # Is this a wiki page? 
  is_wiki <- grepl("^wiki\\/", repo_name)
  
  # There's not remote branches for wiki
  if (is_wiki) {
    branch = ""
  }
  
  if (!is.null(repo_name)) {
    
    # check_git_repo() does not work for wiki pages
    if (!is_wiki) {
      exists <- cow::check_git_repo(
        repo_name = repo_name,
        git_pat = git_pat,
        verbose = FALSE,
        silent = TRUE
      )
      if (!exists) {
        warning(paste(repo_name, "was not found in GitHub. If it is a private repository, make sure your credentials have been provided"))
      }
    }
    
    # Create folder if it doesn't exist
    if (!dir.exists(dest_dir)) {
      dir.create(dest_dir, recursive = TRUE)
    }
    
    dest_file <- file.path(dest_dir, doc_name)
    
    # Piece together URL
    full_url <- file.path(base_url, repo_name, branch, doc_path)
    
    # Download it
    response <- try(download.file(full_url, destfile = dest_file, quiet = TRUE))
    
    # Let us know if the url didn't work
    if (grepl("Error", response)) {
      stop("URL failed: ", full_url, "\n Double check doc_path and repo_name (and branch if set)")
    }
  } else {
    # If the file is local we don't need to download anything
    dest_file <- doc_path
  }
  
  # Remove leanbuild::set_knitr_image_path() from downloaded file
  file_contents <- readLines(dest_file)
  file_contents <- gsub("leanbuild::set_knitr_image_path\\(\\)", "", file_contents)
  writeLines(file_contents, dest_file)
  
  # Set the root directory based on the parent directory that this is being called at
  knitr::opts_knit$set(root.dir = rprojroot::find_root(knitr::current_input()))
  
  # Knit it in
  result <- knitr::knit_child(dest_file, 
                              options = list(echo = FALSE, 
                                             results = 'asis'), 
                              quiet = FALSE)
  cat(result, sep = "\n")
}
