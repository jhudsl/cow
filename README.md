### githubr

`githubr` is a GitHub API wrapper package for R. 

It includes mainly functions that help with GitHub based courses including retrieving chapter names and learning objectives for courses hosted on GitHub repositories.

[Read the full documentation here](https://jhudatascience.org/githubr/index.html).

## Installation

You can install `githubr` from GitHub with:

```
if (!(installed.packages() %in% "remotes")){
  install.packages("remotes")
}
remotes::install_github("jhudsl/githubr")
```

If you prefer to install with binary you can install like this: 
```
install.packages('https://github.com/jhudsl/cow/raw/main/package_bundles/cow_0.0.0.9000.tgz', repos = NULL)
```

For quick start up, or if you have installation problems, you can use the docker image:

```
docker run -it -v $PWD:/home/rstudio -e PASSWORD=password -p 8787:8787 jhudsl/course-library
```
Then in the browser of your choice, navigate to localhost:8787 and install from GitHub if you want the latest version.
```
remotes::install_github("jhudsl/githubr")
```

## Set up with GitHub token

If you want `githubr`, to have full capabilities you will need to give give your local RStudio a GitHub token.
To do this, run this command:

```
usethis::create_github_token()
```
You should only need to do this once per RStudio environment.
If you don't supply a token this way, then private repositories (or those you don't have permissions to access) will not be able to be accessed.

### Quick examples of what this package does:

Check if a repository exists in GitHub:

```
githubr::check_git_repo("jhudsl/OTTR_Template")
```

Get all repository names for an organization:

```
githubr::retrieve_org_repos(org_name = "jhudsl", output_file = "jhudsl_repos.tsv")
```

Get bookdown chapters for a repository:

```
githubr::get_chapters("jhudsl/Documentation_and_Usability")
```

Get keywords for a html page at a url:

```
keywords_df <- githubr::get_keywords(url)
```

Get learning objectives for a bookdown chapter at a url:

```
keywords_df <- githubr::get_learning_obj(url)
```

Get all bookdown chapters for a all repositories in an organization:
```
githubr::retrieve_org_chapters(org_name = "jhudsl", output_file = "chapter_info.tsv")
```

Borrow a Rmd or md chapter between courses. 
```
githubr::borrow_chapter(repo_name = "jhudsl/OTTR_Template", "02-chapter-of-course.Rmd")
```


```
