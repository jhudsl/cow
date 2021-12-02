FROM rocker/tidyverse:4.0.2
LABEL maintainer="cansav09@gmail.com"
WORKDIR /rocker-build/

# Copy over git token and package list
COPY install_github.R .
COPY git_token.txt .
COPY github_package_list.tsv .

# Install apt-getable packages to start
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils dialog

# Add curl, bzip2
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    bzip2 \
    curl

# Commonly used R packages
RUN Rscript -e  "install.packages( \
    c('optparse', \
    'htm2txt', \
    'udpipe', \
    'xml2', \
    'rvest', \
    'jsonlite', \
    'stringi'))"

# Install packages from github
RUN Rscript install_github.R \
  --packages github_package_list.tsv \
  --token git_token.txt

# Set final workdir for commands
WORKDIR /home/rstudio
