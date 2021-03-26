FROM ubuntu:20.04
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

ENV COMPOSER_PROCESS_TIMEOUT=3600
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/Berlin"

RUN apt-get -y update && \
    apt-get -y install apt-utils git curl composer apache2 nano php php-xml php-fpm && \
    rm -rf /var/lib/apt/lists/*

# node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get -y install nodejs
RUN node -v

RUN mkdir -p /run/php
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php/7.4/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php/7.4/fpm/php.ini
RUN echo "max_execution_time = 10000;" >> /etc/php/7.4/fpm/php.ini
RUN echo "date.timezone = Europe/Berlin;" >> /etc/php/7.4/fpm/php.ini
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.4/fpm/php-fpm.conf

## download and build gitlist
RUN git clone https://github.com/grimbough/gitlist.git 
WORKDIR ./gitlist
RUN ./scripts/build.sh
RUN ln -s /gitlist/build/p3x-gitlist /var/www/gitlist
RUN mkdir -p /var/git

## configure apache2
RUN sed -i 's=Listen 80=Listen 8080=g' /etc/apache2/ports.conf
RUN sed -i 's=:80>=:8080>=g' /etc/apache2/sites-available/000-default.conf 
RUN sed -i 's=/var/www/html=/var/www/gitlist/public=g' /etc/apache2/sites-available/000-default.conf 
ADD gitlist.conf /etc/apache2/conf-available/
RUN a2enconf gitlist
RUN a2enconf php7.4-fpm
RUN a2enmod rewrite

## custom home page
ADD css /var/www/gitlist/public/css
ADD json.html /var/www/gitlist/public/index.html
RUN ln -s /var/git/packages.json /var/www/gitlist/public

## set permissions
RUN chown -R www-data:www-data /var/www/gitlist
RUN chown -R www-data:www-data /var/git
RUN chown -R www-data:www-data /gitlist/build/p3x-gitlist/cache

EXPOSE 8080

CMD ["apachectl", "-D", "FOREGROUND"]
