FROM nginxinc/nginx-unprivileged:alpine3.21-perl 
LABEL maintainer "Mike Smith <mike.smith@embl.de>"
ENV TZ="Europe/Berlin"

COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

ADD images/favicon.tar.gz ./
COPY images images/

COPY css css/
COPY html/* ./

USER root
## This is just a symlink.  
## The actual file is created on a shared PVC by the git updater job
RUN ln -s /var/shared/sitemap.txt sitemap.txt
RUN ln -s /var/shared/robots.txt robots.txt
USER nginx

EXPOSE 8080
