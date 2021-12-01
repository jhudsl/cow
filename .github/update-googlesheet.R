# Update the jhu course library googlesheet
# C. Savonen 2021

if (!(installed.packages() %in% "remotes")){
  install.packages("remotes")
}

if (!(installed.packages() %in% "gitHelpeR")){
  remotes::install_github("jhudsl/gitHelpeR")
}

chapter_df <-
  gitHelpeR::retrieve_org_chapters(org_name = "jhudsl",
                                   output_file = "jhudsl_chapter_info.tsv",
                                   retrieve_learning_obj = TRUE)

googlesheets4::sheet_write(data = chapter_df,
  googledrive::as_id("https://docs.google.com/spreadsheets/d/14KYZA2K3J78mHVCiWV6-vkY6it37Ndxnow1Uu7nMa80/edit#gid=0"),
  sheet = 1)

