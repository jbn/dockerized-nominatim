#!/bin/bash

# Turn postgresql fsync and full_page_writes back on.
# See: http://wiki.openstreetmap.org/wiki/Nominatim/Installation#PostgreSQL_Tuning

sed -i \
    -e "s/fsync = off/#fsync = on/" \
    -e "s/full_page_writes = off/#full_page_writes = on/" \
    /etc/postgresql/9.3/main/postgresql.conf
