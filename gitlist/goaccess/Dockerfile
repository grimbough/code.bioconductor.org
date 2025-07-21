# Use Alpine as the base image
FROM alpine:3.22

ENV GOACCESS_VERSION="1.9.4"
ENV GEOLITE_CITY_LINK="https://git.io/GeoLite2-City.mmdb"

# Main application directory
WORKDIR /var/goaccess

# Install build and runtime dependencies
RUN apk add --no-cache \
    build-base \
    ncurses-dev \
    autoconf \
    automake \
    git \
    gettext-dev \
    libmaxminddb-dev \
    libmaxminddb \
    wget \
    ncurses \
    libintl

# Build and install GoAccess
RUN wget -q -O - https://github.com/allinurl/goaccess/archive/v${GOACCESS_VERSION}.tar.gz | tar --strip 1 -xzf - && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install

# Clean up build artifacts
RUN apk del build-base ncurses-dev autoconf automake git gettext-dev && \
    rm -rf /app/*

# Download GeoLite2 City database
RUN mkdir -p /usr/local/share/GeoIP
RUN wget -q -O /usr/local/share/GeoIP/GeoLite2-City.mmdb ${GEOLITE_CITY_LINK}

# Copy configuration files
COPY ./goaccess.conf /opt/goaccess.conf

RUN addgroup -g 101 nginx && \
    adduser -u 101 -G nginx -D nginx

USER nginx

# Run the application
ENTRYPOINT ["sh", "-c", "goaccess /var/log/nginx/access.log* --unknowns-as-crawlers --persist --restore --db-path=/var/log/nginx/goaccess --config-file=/opt/goaccess.conf"]

