FROM r-base:4.0.4
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

RUN apt-get update -y && apt-get install -y libgit2-dev libssl-dev libxml2-dev libcurl4-openssl-dev

RUN Rscript -e "install.packages(c('dplyr', 'lubridate', 'tidyRSS', 'gert', 'jsonlite'))"

ADD check_rss_feed.R /root/

WORKDIR /root

ENTRYPOINT ["Rscript", "check_rss_feed.R"]