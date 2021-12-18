### :cow: Course Organizer and Wrangler - COW.

`cow` accesses GitHub API from R and performs some course management functions, including retrieving chapter names and learning objectives for courses hosted on GitHub repositories.

[Read the full documentation here](https://jhudatascience.org/cow/index.html).

## Installation

You can install `cow` from GitHub with:

```
if (!(installed.packages() %in% "remotes")){
  install.packages("remotes")
}
remotes::install_github("jhudsl/cow")
```

For quick start up, or if you have installation problems, you can use the docker image:

```
docker run -it -v $PWD:/home/rstudio -e PASSWORD=password -p 8787:8787 jhudsl/course-library
```
Then in the browser of your choice, navigate to localhost:8787 and install from GitHub if you want the latest version.
```
remotes::install_github("jhudsl/cow")
```

## Set up with GitHub token

If you want `cow`, to have full capabilities you will need to give give your local RStudio a GitHub token.
To do this, run this command:

```
usethis::create_github_token()
```
You should only need to do this once per RStudio environment.
If you don't supply a token this way, then private repositories (or those you don't have permissions to access) will not be able to be accessed.

### Quick examples of what this package does:

Check if a repository exists in GitHub:

```
cow::check_git_repo("jhudsl/OTTR_Template")
```

Get all repository names for an organization:

```
cow::retrieve_org_repos(org_name = "jhudsl", output_file = "jhudsl_repos.tsv")
```

Get bookdown chapters for a repository:

```
cow::get_chapters("jhudsl/Documentation_and_Usability")
```

Get keywords for a html page at a url:

```
keywords_df <- cow::get_keywords(url)
```

Get learning objectives for a bookdown chapter at a url:

```
keywords_df <- cow::get_learning_obj(url)
```

Get all bookdown chapters for a all repositories in an organization:
```
cow::retrieve_org_chapters(org_name = "jhudsl", output_file = "jhudsl_chapter_info.tsv")
```

Borrow a Rmd or md chapter between courses. 
```
cow::borrow_chapter(repo_name = "jhudsl/OTTR_Template", "02-chapter-of-course.Rmd")
```


```
