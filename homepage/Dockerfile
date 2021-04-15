FROM alpine:3.13

RUN apk update \
    && apk add lighttpd bash \
    && rm -rf /var/cache/apk/*

RUN sed -i 's/# server.port          = 81/server.port = 8080/g' /etc/lighttpd/lighttpd.conf

RUN mkdir -p /var/www/localhost/htdocs
WORKDIR /var/www/localhost/htdocs

COPY images images/
RUN tar xzvf images/favicon.tar.gz

COPY css css/

COPY html/*.html ./

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
