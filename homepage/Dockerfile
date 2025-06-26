FROM alpine:3.17

RUN apk update \
    && apk add lighttpd bash \
    && rm -rf /var/cache/apk/*

#RUN sed -i 's/# server.port          = 81/server.port = 8080/g' /etc/lighttpd/lighttpd.conf
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

RUN mkdir -p /var/www/localhost/htdocs /var/shared
WORKDIR /var/www/localhost/htdocs

COPY images images/
RUN tar xzvf images/favicon.tar.gz

COPY css css/

COPY html/* ./

## This is just a symlink.  
## The actual file is created on a shared PVC by the git updater job
RUN ln -s /var/shared/sitemap.txt sitemap.txt
RUN ln -s /var/shared/robots.txt robots.txt

RUN touch /run/lighttpd.pid && chown -R 100:100 /run/lighttpd.pid

USER lighttpd

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
