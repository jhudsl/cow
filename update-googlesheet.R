# Update the jhu course library googlesheet
# C. Savonen 2021

############################## Set up Functions ################################
authorize_from_secret <- function(access_token, refresh_token) {
  client_id <- getOption("slides.client.id")
  client_secret <- getOption("slides.client.secret")

  credentials <- list(
    access_token = access_token,
    expires_in = 3599L,
    refresh_token = refresh_token,
    scope = "https://www.googleapis.com/auth/sheets https://www.googleapis.com/auth/drive.readonly",
    token_type = "Bearer"
  )

  app <- httr::oauth_app(
    appname = "googleslides",
    key = client_id,
    secret = client_secret
  )
  endpoint <- httr::oauth_endpoints("google")

  token <- httr::oauth2.0_token(
    endpoint = endpoint, app = app,
    scope = c(
      "https://www.googleapis.com/auth/presentations",
      "https://www.googleapis.com/auth/drive.readonly"
    ),
    credentials = credentials
  )

  return(token)
}


library(optparse)

################################ Set up options ################################
# Set up optparse options.
option_list <- list(
  make_option(
    opt_str = c("-r", "--refresh_token"), type = "character",
    default = NULL, help = "Can be obtained from: auth <- googlesheets4::gs4_auth_configure() auth$cred$credentials",
    metavar = "character"
  ),
  make_option(
    opt_str = c("-a", "--access_token"), type = "character",
    default = NULL, help = "Can be obtained from: auth <- googlesheets4::gs4_auth_configure() auth$cred$credentials",
    metavar = "character"
  )
)

# Parse options
opt <- parse_args(OptionParser(option_list = option_list))

authorize_from_secret(
  opt$access_token,
  opt$refresh_token
)

# We will load the latest gitHelpeR package root
root_dir <- rprojroot::find_root(rprojroot::has_file("gitHelpeR.Rproj"))

devtools::load_all(root_dir)

# Run onjhudsl org and retrieve keywords and learning objectives
chapter_df <-
  gitHelpeR::retrieve_org_chapters(
    org_name = "jhudsl",
    git_pat = readLines("git_token.txt"),
    output_file = "jhudsl_chapter_info.tsv",
    retrieve_learning_obj = TRUE,
    retrieve_keywords = TRUE,
    verbose = FALSE
  )

file.remove("git_token.txt")



# Save to googlseheet
googlesheets4::sheet_write(
  data = chapter_df,
  googledrive::as_id("https://docs.google.com/spreadsheets/d/14KYZA2K3J78mHVCiWV6-vkY6it37Ndxnow1Uu7nMa80/edit#gid=0"),
  sheet = 1
)
