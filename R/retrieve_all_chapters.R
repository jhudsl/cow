
retrieve_all_chapters <- function(org_name = "jhudsl",
                                  url_base = "http://jhudatascience.org/",
                                  output_file = "jhudsl_chapter.tsv") {

  # Declare file name for this organization
  json_file <- paste0(org_name, "-repos.json")

  # Download the repos and save to file
  curl_command <-
    paste0("curl -H 'Accept: application/vnd.github.v3+json' https://api.github.com/orgs/",
           org_name,
           "/repos?per_page=1000000 > ",
           json_file)

  # Run the command
  system(curl_command)

  # Read in json file
  repos <- jsonlite::read_json(json_file)

  # Collect repo names
  repo_names_index <- grep("^name$", names(unlist(repos)))
  repo_names <- unlist(repos)[repo_names_index]

  all_chapters <- lapply(repo_names,
                         get_chapters,
                         url_base = url_base) %>%
    dplyr::bind_rows() %>%
    readr::write_tsv(output_file)

  return(all_chapters)
}
