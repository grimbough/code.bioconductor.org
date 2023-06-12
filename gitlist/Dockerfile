FROM alpine:3.16.4 AS builder
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


FROM ubuntu:22.04 
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/Berlin"

RUN apt-get -y update && \
    apt-get -y install git php php-xml php-fpm nano && \
    rm -rf /var/lib/apt/lists/*

## configure php
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php/8.1/fpm/php.ini && \
    echo "max_input_vars = 10000;" >> /etc/php/8.1/fpm/php.ini && \
    echo "max_execution_time = 10000;" >> /etc/php/8.1/fpm/php.ini && \
    echo "date.timezone = Europe/Berlin;" >> /etc/php/8.1/fpm/php.ini
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/8.1/fpm/php-fpm.conf

## configure apache2
RUN sed -i 's=Listen 80=Listen 8080=g' /etc/apache2/ports.conf
RUN sed -i 's=:80>=:8080>=g' /etc/apache2/sites-available/000-default.conf 
ADD gitlist.conf /etc/apache2/conf-available/
RUN a2enconf gitlist && \
    a2enconf php8.1-fpm && \
    a2enmod rewrite

COPY --from=builder /gitlist /var/www/html/browse
COPY --from=builder /bioconductor /var/www/html/browse/themes/bioconductor
RUN mkdir /var/www/html/browse/cache

RUN ln -s /var/git/packages.json /var/www/html/browse/ && \
    ln -s /var/git/status.log /var/www/html/browse/

## map www-data to the same UID as Alpine uses
## then set permissions
RUN usermod -u 82 www-data && groupmod -g 82 www-data && \
    chown -R www-data:www-data /var/www/html

EXPOSE 8080

CMD ["apachectl", "-D", "FOREGROUND"]
