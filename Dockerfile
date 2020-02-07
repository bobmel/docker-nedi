FROM bobmel/nginx-php-fpm:edge
LABEL maintainer="Bob Melander (bob dot melander at gmail dot com)"

### Set some default values
ENV DB_HOST=mariadb \
    DB_NAME=nedi \
    DB_USER=nedi \
    ENABLE_MONITORING_SERVICE=TRUE \
    ENABLE_SYSLOG_SERVICE=FALSE \
    ENABLE_NETFLOW_SERVICE=FALSE \
    ENABLE_SMTP=FALSE \
    ENABLE_ZABBIX=FALSE \
    NFDUMP_DATA_BASE_DIR=/data/nfdump/datafiles \
    NEDI_CERT_INFO="/C=CH/ST=ZH/L=Zurich/O=NeDi Consulting/OU=R&D" \
    NEDI_SOURCE_URL=http://www.nedi.ch/pub \
    NEDI_VERSION=1.8C \
    PHP_INI_FILE=/etc/php7/php.ini

### Install NeDi required packages
RUN apk update && \
    apk upgrade && \
    apk add \
    openssl \
    perl-algorithm-diff \
    perl-dbd-mysql \
    perl-dbi \
    perl-net-snmp \
    perl-net-telnet \
    perl-rrd \
    perl-socket6 
    
### Install and tune NeDi community edition
RUN adduser -H -s /sbin/nologin -D nedi && \ 
    mkdir -p /data/nedi && \
    cd /data/nedi && \
    wget ${NEDI_SOURCE_URL}/nedi-${NEDI_VERSION}.pkg && \
    tar -xf /data/nedi/nedi*.pkg && \
    rm nedi*.pkg && \
    mkdir -p /data/nedi/ssl/private && \
    chown -R nedi:nedi /data/nedi && \
    mkdir -p /data/log/nedi && \
    chown -R nedi.nedi /data/log/nedi && \
    ln -s /data/nedi/nedi.conf /etc/nedi.conf && \
    sed -i '/nedipath/s/\/var\/nedi/\/data\/nedi/g' /data/nedi/nedi.conf && \
    sed -i '/dbhost/s/localhost/'"${DB_HOST}"'/g' /data/nedi/nedi.conf && \
    sed -i '/dbuser/s/nedi/'"${DB_USER}"'/g' /data/nedi/nedi.conf && \
    sed -i '/dbname/s/nedi/'"${DB_NAME}"'/g' /data/nedi/nedi.conf && \
    sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 2G/"  "${PHP_INI_FILE}" && \
    sed -i -e "s/^post_max_size.*/post_max_size = 1G/"  "${PHP_INI_FILE}" && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig

### Networking Configuration
EXPOSE 80 162/UDP 443 514/UDP

### Files Addition
ADD install /

WORKDIR /data/nedi/
