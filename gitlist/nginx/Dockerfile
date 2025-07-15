FROM nginxinc/nginx-unprivileged:alpine3.21-perl 
LABEL maintainer "Mike Smith <mike.smith@embl.de>"
ENV TZ="Europe/Berlin"

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
