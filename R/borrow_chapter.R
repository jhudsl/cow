#' Borrow/link a chapter from another bookdown course
#'
#' @param doc_path A file path of markdown or R Markdown 
#' document of the chapter in the repository you are retrieving it from that 
#' you would like to include in the current document. e.g "docs/intro.md" or "intro.md"
#' @param repo_name A character vector indicating the repo name of where you are
#'  borrowing from. e.g. "jhudsl/DaSL_Course_Template_Bookdown/". 
#'  For a Wiki of a repo, use "wiki/jhudsl/DaSL_Course_Template_Bookdown/" 
#'  If nothing is provided, will look for local file.
#' @param branch Default is to pull from main branch, but need to declare if other branch is needed.
#' @param git_pat A personal access token from GitHub. Only necessary if the
#' repository being checked is a private repository.
#' @param base_url it's assumed this is coming from github so it is by default 'https://raw.githubusercontent.com/'
#' @param dest_dir A file path where the file should be stored upon arrival to 
#' the current repository. 
#' 
#' @return An Rmarkdown or markdown is knitted into the document from another repository
#' 
#' @importFrom knitr knit_child
#' @importFrom utils download.file
#' @export
#'
#' @examples \dontrun{
#' 
#' # In an Rmarkdown document: 
#' 
#' For a file in another repository:
#' ```{r, echo=FALSE, results='asis'}
#' borrow_chapter(
#' doc_path = "docs/02-chapter_of_course.md",
#' repo_name = "jhudsl/DaSL_Course_Template_Bookdown")
#' ```
#' 
#' 
#' For a local file:
#' ```{r, echo=FALSE, results='asis'}
#' borrow_chapter(doc_path = "02-chapter_of_course.Rmd")
#' ```
#' }
borrow_chapter <- function(
  doc_path,
  repo_name = NULL,
  branch = "main",
  git_pat = NULL,
  base_url = 'https://raw.githubusercontent.com', 
  dest_dir = file.path("resources", "other_chapters")) {
  

  # Declare file names
  doc_path <- file.path(doc_path)
  doc_name <- basename(doc_path)
  
  if (is.null(repo_name)) {
    
    exists <- check_git_repo(
      repo_name = repo_name,
      git_pat = git_pat,
      verbose = FALSE,
      silent = TRUE
    )
  
    # Create folder if it doesn't exist
    if (!dir.exists(dest_dir)) {
      dir.create(dest_dir, recursive = TRUE)
    }
  
    dest_file <- file.path(dest_dir, doc_name)
  
    full_url <- file.path(base_url, repo_name, branch, doc_path)
    
    # Progress message
    message(full_url)
    
    # Download it 
    download.file(full_url, destfile = dest_file)
  } else {
    # If the file is local we don't need to download anything
    dest_file <- doc_path
  }
  
  # Knit it in
  result <- knitr::knit_child(dest_file, quiet = TRUE)
  cat(result, sep = '\n')

}

