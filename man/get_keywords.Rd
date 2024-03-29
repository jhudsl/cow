% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_keywords.R
\name{get_keywords}
\alias{get_keywords}
\title{Retrieve keywords for a chapter}
\usage{
get_keywords(url, min_occurrence = 4, udmodel = NULL)
}
\arguments{
\item{url}{a url to a bookdown chapter
e.g. "https://jhudatascience.org/Documentation_and_Usability/what-does-good-documentation-look-like.html"}

\item{min_occurrence}{A numeric number specifying the minimum number of times a keyword should appear for it to stay in the list. Default is 4.}

\item{udmodel}{A udmodel passed in for keyword determination. Will be obtained using
\code{udpipe::udpipe_download_model(language = "english")} if its not given.}
}
\value{
a data frame of keywords
}
\description{
Given an URL to a bookdown chapter, extract the keywords
}
\examples{

# Declare chapter URL
url <- "https://jhudatascience.org/Documentation_and_Usability/other-helpful-features.html"

keywords_df <- get_keywords(url)
}
