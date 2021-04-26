FROM alpine:3.13.2 AS zoekt-index

RUN apk --no-cache add go git

ENV CGO_ENABLED=0

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-index



FROM alpine:3.13.2 AS ctags

RUN apk --no-cache add wget

ENV CTAGS_BIN ctags-2020-08-26T1308-c9ebd839

RUN wget https://storage.googleapis.com/zoekt-binaries/${CTAGS_BIN}.tar.gz && \
    tar -xvzf ${CTAGS_BIN}.tar.gz && \
    mv ${CTAGS_BIN} ctags && \
    chmod +rx ctags/*



FROM alpine:3.13.2
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

COPY --from=ctags /ctags/* /usr/local/bin/
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
             -e "install.packages(c('dplyr', 'tidyRSS', 'gert', 'jsonlite'), quiet = TRUE)"

RUN adduser --disabled-password --uid 82 www-data
USER www-data

COPY *.R /var/R/
WORKDIR /var/R

ENTRYPOINT ["Rscript", "check_rss_feed.R"]
