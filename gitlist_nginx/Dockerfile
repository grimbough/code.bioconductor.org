FROM alpine:3.16 AS builder
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

ENV TZ="Europe/Berlin"

RUN apk --no-cache add \
        curl \
        git \
        nodejs-less \
        unzip

WORKDIR /
RUN curl -L --output gitlist.zip https://github.com/klaussilveira/gitlist/releases/download/1.1.1/gitlist-1.1.1.zip && unzip gitlist.zip -d gitlist
COPY config.ini /gitlist/config.ini
COPY json.html /gitlist/index.html
COPY php/Repository.php /gitlist/src/Util/Repository.php

COPY bioconductor /bioconductor
WORKDIR /bioconductor/less
RUN test -d "/bioconductor/less/bootstrap-less" && echo "HERE" || git clone https://github.com/distros/bootstrap-less
WORKDIR /bioconductor
RUN lessc less/style.less > css/style.css


FROM nginxinc/nginx-unprivileged:alpine3.21-perl 
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

ENV TZ="Europe/Berlin"

USER root

RUN apk add --no-cache \
    bash \
    coreutils \
    git \
    grep \
    mercurial \
    make \
    wget \
    php82-fpm \
    php82-session \
    php82-dom \
    php82-exif \
    php82-gettext \
    php82-intl \
    php82-opcache \
    php82-sockets \
    php82-xsl \
    php82-zip \
    php82-pecl-apcu \
    php82-pecl-xdebug \
    nano

COPY --from=builder /gitlist /usr/share/nginx/html/browse
COPY --from=builder /bioconductor /usr/share/nginx/html/browse/themes/bioconductor

RUN mkdir -p /usr/share/nginx/html/browse/cache /usr/share/nginx/html/browse/logs /var/git/

RUN ln -s /var/git/packages.json /usr/share/nginx/html/browse/ && \
    ln -s /var/git/status.log /usr/share/nginx/html/browse/

COPY php/phpinfo.php /usr/share/nginx/html/browse/

RUN chown nginx:nginx -R /usr/share/nginx/html/ /var/log/php82 /var/log/nginx /var/git

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY www.conf /etc/php82/php-fpm.d/www.conf

RUN sed -i 's#;error_log = php_errors.log#error_log = /var/log/php82/error.log#g' /etc/php82/php.ini

EXPOSE 8080

USER nginx

CMD ["sh", "-c", "php-fpm82 -D && nginx -g 'daemon off;'"]

