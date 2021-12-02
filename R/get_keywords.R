#' Retrieve keywords for a chapter
#'
#' Given an URL to a bookdown chapter, extract the keywords
#'
#' @param chapt_url a url to a bookdown chapter
#' e.g. "https://jhudatascience.org/Documentation_and_Usability/what-does-good-documentation-look-like.html"
#' @param min_occurrence A numeric number specifying the minimum number of times a keyword should appear for it to stay in the list. Default is 4.
#'
#' @return a data frame of keywords
#'
#' @importFrom magrittr %>%
#' @importFrom udpipe udpipe_download_model
#' @importFrom udpipe  udpipe_load_model
#' @importFrom textrank textrank_keywords
#' @import dplyr
#'
#' @export
#'
#' @examples
#'
#' # Declare chapter URL
#' url <- "https://jhudatascience.org/Documentation_and_Usability/what-does-good-documentation-look-like.html"
#'
#' keywords_df <- get_keywords(url)
#'
get_keywords <- function(url, min_occurrence = 4, udmodel = NULL) {

  # Get text from chapter url
  text <- htm2txt::gettxt(url)

  text <- gsub("\n|•", "", text)

  # Only keep sensible text
  text <- iconv(text, to = "UTF-8")

  # Remove blank strings
  text <- text[which(text != "")]

  # Set up udmodel to get parts of speech
  if (is.null(udmodel)) {
    udmodel <- udpipe::udpipe_download_model(language = "english")
    udmodel <- udpipe::udpipe_load_model(file = udmodel$file_model)
  }

  # Annotat parts of speech
  text_modeled <- udpipe_annotate(udmodel, text)

  # Filter out jumbly stuffs
  text_df <- as.data.frame(text_modeled) %>%
    dplyr::filter(!grepl("^\\.|^\\-", token))

  # Get stats for only adjectives and nouns
  stats <- textrank::textrank_keywords(text_df$lemma,
                                       relevant = text_df$upos %in% c("ADJ", "NOUN"))

  # Retrieve the keywords
  keywords <- data.frame(stats$keywords) %>%
    dplyr::filter(freq > min_occurrence) %>%
    dplyr::pull(keyword)

  return(paste0(keywords, collapse = ","))
}
