# hub.docker.com/r/bobmel/nedi

# Introduction

Dockerfile to build a [Nedi](http://www.nedi.ch) container image for Wandboard Quad (armhf architecture). It probably works for other ARM-based computers like the Raspberry Pi but that's *not tested*.

* NeDi discovers your network devices and tracks connected end-nodes. Some of its features are:
    * Topology awareness and network maps
    * Traffic graphing
    * Uptime, BGP peer and interface status monitoring
    * Extensive reporting ranging from devices, modules and interfaces 
* This container uses a [customized Nginx with Php-FPM](https://hub.docker.com/r/tiredofit/nginx-php-fpm) which includes [s6 overlay](https://github.com/just-containers/s6-overlay) enabled for PID 1 Init capabilities, [zabbix-agent](https://zabbix.org) for individual container monitoring, Cron also installed along with other tools (bash,curl, less, logrotate, mariadb-client, nano, vim) for easier management. It also supports sending to external SMTP servers.


[Changelog](CHANGELOG.md)

# Authors

- [Bob Melander](http://github/bobmel/)

# Table of Contents

- [Introduction](#introduction)
    - [Changelog](CHANGELOG.md)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Database](#database)
    - [Data Volumes](#data-volumes)
    - [Environment Variables](#environmentvariables)
    - [Networking](#networking)
- [Maintenance](#maintenance)
    - [Shell Access](#shell-access)
   - [References](#references)

# Prerequisites

This image assumes that you are using a reverse proxy such as [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) and optionally the [Let's Encrypt Proxy Companion @ https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) in order to serve your pages. However, it will run just fine on it's own if you map appropriate ports.

# Installation

Builds of the image are available on [Registry](https://hub.docker.com/bobmel/nedi) and is the recommended method of installation.


```bash
docker pull hub.docker.com/bobmel/nedi:(imagetag)
```

The following image tags are available:

* `latest` - Nedi 1.8C with PHP 7.3.x w/Alpine edge


# Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

# Configuration

### Data-Volumes

When the container starts up for the first time it downloads and installs Nedi in `/data/nedi`. Nedi's  configuration file, `/etc/nedi.conf`, is a symlink to `/data/nedi/nedi.conf`. Nginx's default server config `/etc/nginx/conf.d/default.conf` is a symlink to Nedi's web server configuration file `/etc/nginx/conf.d/default.conf/default_nedi.conf`.

The following directory is used for configuration and can be mapped for persistent storage.


| Directory    | Description               |
|--------------|---------------------------|
| `/data/nedi` | Data Persistence for Nedi |

Additional directories as specified in the [Base image](https://hub.docker.com/r/tiredofit/alpine), the [Nginx Base](https://hub.docker.com/t/tiredofit/nginx), and [Nginx with Php-FPM](https://hub.docker.com/r/tiredofit/nginx-php-fpm) can also be mapped to the host for persistent storage.


### Database

A separately running MariaDB instance is required. The database to use is set using environment variables.
See the [Environment Variables](#environmentvariables) section for details.

### Environment Variables

Below is a list of available options that can be used to customize your installation.

| Parameter                   | Description                                                                     |
|-----------------------------|---------------------------------------------------------------------------------|
| `DB_HOST`                   | Name (or IP) of host/container running MariaDB (default: `nedi`)                |
| `DB_NAME`                   | Name of the Nedi database (default: `nedi`)                                     |
| `DB_USER`                   | Username for Nedi to use with MariaDB (default: `nedi`)                         |
| `DB_PASS`                   | Password for Nedi to use with MariaDB (***required***)                          |
| `ROOT_PASS`                 | Password for root user on MariaDB host (***required***)                         |
| `ENABLE_MONITORING_SERVICE` | Enable/disable Nedi monitoring service (default: `TRUE`)                        |
| `ENABLE_SYSLOG_SERVICE`     | Enable/disable Nedi syslog service (default: `FALSE`)                           |
| `ENABLE_NETFLOW_SERVICE`    | Enable/disable Netflow service (default: `FALSE`)                               |
| `NEDI_CERT_INFO`            | SSL Certificate data (default: `/C=CH/ST=ZH/L=Zurich/O=NeDi Consulting/OU=R&D)` |
| `NEDI_SOURCE_URL`           | Nedi source URL (default: `http://www.nedi.ch/pub`)                             |
| `NEDI_VERSION`              | Nedi version (default: `1.8C`)                                                  |
| `PHP_INI_FILE`              | Location of configuration file for php (default: `1/etc/php7/php.ini`)          |

Additional options can be found the [Base image](https://hub.docker.com/r/tiredofit/alpine), the [Nginx Base](https://hub.docker.com/t/tiredofit/nginx), and [Nginx with Php-FPM](https://hub.docker.com/r/tiredofit/nginx-php-fpm).

### Networking

The following ports are exposed.

| Port      | Description                                          |
|-----------|------------------------------------------------------|
| `80`      | Nedi HTTP web interface (*not enabled by default*)   |
| `162 UDP` | Nedi monitoring service                              |
| `443`     | Nedi HTTPS web interface                             |
| `514 UDP` | Nedi Syslog service                                  |

# Maintenance
#### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is, e.g., nedi) bash
```

# References

* https://www.nedi.ch
* https://www.nginx.org
* http://www.php.org

