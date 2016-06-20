#!/bin/bash

# Turn off postgresql fsync and full_page_writes, initially.
# See: http://wiki.openstreetmap.org/wiki/Nominatim/Installation#PostgreSQL_Tuning

sed -i \
    -e "s/#fsync = on/fsync = off/" \
    -e "s/#full_page_writes = on/full_page_writes = off/" \
    /etc/postgresql/9.3/main/postgresql.conf
