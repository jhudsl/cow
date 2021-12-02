# Update the jhu course library googlesheet
# C. Savonen 2021

needed_packages <- c("devtools", "gitcreds", "htm2txt", "textrank", "udpipe")

lapply(needed_packages, function(package_name) {
  if (!(package_name %in% installed.packages())){
    install.packages(package_name, repos = "http://cran.us.r-project.org")
  }
})


# We will load the latest gitHelpeR package root
root_dir <- rprojroot::find_root(rprojroot::has_file("gitHelpeR.Rproj"))

devtools::load_all(root_dir)

# Run onjhudsl org and retrieve keywords and learning objectives
chapter_df <-
  gitHelpeR::retrieve_org_chapters(org_name = "jhudsl",
                                   git_pat = readLines("git_token.txt"),
                                   output_file = "jhudsl_chapter_info.tsv",
                                   retrieve_learning_obj = TRUE,
                                   retrieve_keywords = TRUE,
                                   verbose = FALSE)

file.remove("git_token.txt")

# Save to googlseheet
googlesheets4::sheet_write(data = chapter_df,
  googledrive::as_id("https://docs.google.com/spreadsheets/d/14KYZA2K3J78mHVCiWV6-vkY6it37Ndxnow1Uu7nMa80/edit#gid=0"),
  sheet = 1)
