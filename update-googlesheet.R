# Update the jhu course library googlesheet
# C. Savonen 2021

# We will load the latest cow package root
root_dir <- rprojroot::find_root(rprojroot::has_file("cow.Rproj"))

library(googlesheets4)

googlesheets4::gs4_deauth()

if (interactive()){
  gs4_auth(
    email = "cansav09@gmail.com",
    scopes = c("https://www.googleapis.com/auth/spreadsheets","https://www.googleapis.com/auth/drive"),
    cache = file.path(root_dir, ".secrets"),
    #path = file.path(root_dir, "googlesheets-secret.json"),
    use_oob = TRUE
  )
}else{
  gs4_auth(
    email = "cansav09@gmail.com",
    scopes = c("https://www.googleapis.com/auth/spreadsheets","https://www.googleapis.com/auth/drive"),
    cache = file.path(root_dir, ".secrets"),
    use_oob = TRUE,
    #path = file.path(root_dir, "googlesheets-secret.json"),
  )
}

library(optparse)

spreadsheet_url <- "https://docs.google.com/spreadsheets/d/14KYZA2K3J78mHVCiWV6-vkY6it37Ndxnow1Uu7nMa80/edit#gid=0"

################################ Set up options ################################
# Set up optparse options.
option_list <- list(
  make_option(
    opt_str = c("-t", "--token_rds"), type = "character",
    default = NULL, help = "path to google sheets token saved to rds file",
    metavar = "character"
  )
)

# Parse options
opt <- parse_args(OptionParser(option_list = option_list))

# load latest
devtools::load_all(root_dir)

# Run onjhudsl org and retrieve keywords and learning objectives
chapter_df <-
  cow::retrieve_org_chapters(
    org_name = "jhudsl",
    git_pat = readLines(file.path(root_dir, "git_token.txt"))[1],
    output_file = "jhudsl_chapter_info.tsv",
    retrieve_learning_obj = TRUE,
    retrieve_keywords = TRUE,
    verbose = FALSE
  )

file.remove("git_token.txt")

# Save to googlseheet
googlesheets4::sheet_write(
  data = chapter_df,
  googledrive::as_id(spreadsheet_url),
  sheet = 1
)

message(paste0("spreadsheet updated here: ", spreadsheet_url))
