#! /bin/bash

# ----------------------------------------------------------

# Internal Webserver Config

# these are for debugging purposes or
# if you don't want to use the Nginx Reverse Proxy
CFG_MDB_APACHE_SERVER_HTTP_PORT_ON_HOST="8050"
CFG_MDB_APACHE_SERVER_HTTPS_PORT_ON_HOST="6443"

# MySQL/MariaDB Config

# only for debugging purposes
CFG_MDB_MARIADB_SERVER_PORT_ON_HOST="3386"

CFG_MDB_MARIADB_MODOBOA_DBS_PREFIX="mdb_"

# Modoboa Configuration

# !! only in CFG_MDB_TIMEZONE are '/'s allowed
CFG_MDB_TIMEZONE="Europe/Berlin"

# Language code (e.g. 'de' or 'en')
CFG_MDB_LANGUAGE="de"

# CalDAV + CardDAV Server Hostname
CFG_MDB_DAVHOSTNAME="dav"

CFG_MDB_MAILHOSTNAME="mail"
CFG_MDB_MAILDOMAIN="localdomain.local"

# may be "true" or "false":
CFG_MDB_MODOBOA_CSRF_PROTECTION_ENABLE=false

# may be "true" or "false":
CFG_MDB_CLAMAV_CONF_ENABLE=true

# Docker Network

# IP range for private networks: 172.16.0.0 - 172.31.255.255
CFG_MDB_DOCK_NET_INCL_BITMASK="172.30.21.0/24"

# ----------------------------------------------------------

# For the building process only:
# the first 3 numbers of the network address (e.g. 100.50.25)
# IP range for private networks: 172.16.0.0 - 172.31.255.255
CFG_MKLIVE_DOCK_NET_PREFIX="172.29.21"
