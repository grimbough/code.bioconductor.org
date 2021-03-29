FROM alpine:3.13.2
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

ENV TZ="Europe/Berlin"

## install required system libraries
RUN apk --no-cache add \
        gcc \
        g++ \
        make \
        bash \
        tzdata \
        libgit2-dev \
        curl-dev \
        libxml2-dev \
        openssl-dev \
        R \
        R-dev \
        R-doc

## install required R packages
RUN Rscript  -e "chooseCRANmirror(graphics = FALSE, ind = 1)" \
             -e "install.packages(c('dplyr', 'tidyRSS', 'gert', 'jsonlite'), quiet = FALSE)"

ADD *.R /var/R/

RUN mkdir /var/git

RUN adduser --disabled-password --no-create-home --uid 82 www-data
USER www-data

WORKDIR /var/R

ENTRYPOINT ["Rscript", "check_rss_feed.R"]