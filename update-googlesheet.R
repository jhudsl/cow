# Update the jhu course library googlesheet
# C. Savonen 2021

if (!(installed.packages() %in% "devtools")){
  install.packages("devtools")
}

# We will load the latest gitHelpeR package root
root_dir <- rprojroot::find_root(rprojroot::has_file("gitHelpeR.Rproj"))

if (!(installed.packages() %in% "gitHelpeR")){
  devtools::load_all(root_dir)
}

# Run onjhudsl org and retrieve keywords and learning objectives
chapter_df <-
  gitHelpeR::retrieve_org_chapters(org_name = "jhudsl",
                                   output_file = "jhudsl_chapter_info.tsv",
                                   retrieve_learning_obj = TRUE,
                                   retrieve_keywords = TRUE,
                                   verbose = FALSE)

# Save to googlseheet
googlesheets4::sheet_write(data = chapter_df,
  googledrive::as_id("https://docs.google.com/spreadsheets/d/14KYZA2K3J78mHVCiWV6-vkY6it37Ndxnow1Uu7nMa80/edit#gid=0"),
  sheet = 1)
