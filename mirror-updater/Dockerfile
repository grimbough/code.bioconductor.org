FROM alpine:3.21 AS zoekt-index

RUN apk --no-cache add go git

ENV CGO_ENABLED=0

RUN go install github.com/sourcegraph/zoekt/cmd/zoekt-index@latest


FROM alpine:3.21 AS ctags

RUN apk --no-cache add wget

RUN wget https://raw.githubusercontent.com/sourcegraph/zoekt/refs/heads/main/install-ctags-alpine.sh && \
    chmod +x install-ctags-alpine.sh && \
    ./install-ctags-alpine.sh


FROM alpine:3.21
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

COPY --from=ctags /tmp/ctags-*/* /usr/local/bin/
COPY --from=zoekt-index /root/go/bin/* /usr/local/bin/

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
        R-dev

## install required R packages
RUN Rscript  -e "chooseCRANmirror(graphics = FALSE, ind = 1)" \
             -e "install.packages(c('dplyr', 'tidyRSS', 'gert', 'jsonlite', 'lubridate'), quiet = TRUE)"

#RUN adduser --disabled-password --uid 82 www-data
RUN set -x ; \
  addgroup -g 101 -S nginx ; \
  adduser -u 101 -D -S -G nginx nginx && exit 0 ; exit 1
USER www-data

COPY *.R /var/R/
WORKDIR /var/R

ENTRYPOINT ["Rscript", "check_rss_feed.R", "--npkgs=15"]
