FROM r-base:4.0.4
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

## install required system libraries
RUN apt-get update -y && \
    apt-get install -y libgit2-dev libssl-dev libxml2-dev libcurl4-openssl-dev && \
    rm -rf /var/lib/apt/lists/*

## install required R packages
RUN Rscript -e "install.packages(c('dplyr', 'lubridate', 'tidyRSS', 'gert', 'jsonlite'), quiet = TRUE)"

ADD *.R /root/

RUN mkdir /var/git

WORKDIR /root

ENTRYPOINT ["Rscript", "check_rss_feed.R"]