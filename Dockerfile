FROM ubuntu:14.04

MAINTAINER John Nelson <jbn@abreka.com>

# By default, just grab Monaco. It's a very small PBF, so it's 
# useful for testing. To change this, pass
#     --build-arg PBF=your.pbf
# to the `docker build`.
ARG PBF=monaco-latest.osm.pbf

# Install nessessary package dependencies for Nominatim.
RUN apt-get update && apt-get -y install build-essential libxml2-dev \
    libpq-dev libbz2-dev libtool automake libproj-dev libboost-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev \
    libexpat-dev gcc proj-bin libgeos-c1 libgeos++-dev libexpat-dev \
    php5 php-pear php5-pgsql php5-json php-db libapache2-mod-php5 \
    postgresql postgis postgresql-contrib postgresql-9.3-postgis-2.1 \
    postgresql-server-dev-9.3 wget

# Add my shell scripts.
ADD start.sh /root/start.sh
ADD postgres_install_time.sh /root/postgres_install_time.sh
ADD postgres_post_install.sh /root/postgres_post_install.sh
RUN chmod u+x /root/start.sh
RUN chmod u+x /root/postgres_install_time.sh
RUN chmod u+x /root/postgres_post_install.sh

# Create the nominatim user.
RUN useradd -m -p secret nominatim

# Set up the app file structure and Apache details.
ADD 100-nominatim.conf /etc/apache2/sites-available/100-nominatim.conf
RUN mkdir -p /app && \
    chown nominatim /app && \
    chgrp nominatim /app && \
    mkdir -m 755 /var/www/nominatim && \
    chown nominatim /var/www/nominatim && \
    a2dissite 000-default && \
    a2ensite 100-nominatim

# Download nominatim and add `local.php` settings.
USER nominatim
WORKDIR /app
RUN wget http://www.nominatim.org/release/Nominatim-2.5.0.tar.bz2 && \
    tar xvf Nominatim-2.5.0.tar.bz2 && rm Nominatim-2.5.0.tar.bz2 && \
    mv Nominatim-2.5.0 nominatim
ADD local.php /app/nominatim/settings/local.php

# Build nominatim.
WORKDIR /app/nominatim
RUN ./configure && make

USER root

WORKDIR /app/nominatim

# Set execute/search bits for postgresql to read nominatim.so.
# See: http://wiki.openstreetmap.org/wiki/Nominatim/Installation#Nominatim_module_reading_permissions
RUN chmod +x / && \
    chmod +x /app && \
    chmod +x /app/nominatim/ && \
    chmod +x /app/nominatim/module/

# Add your PBF data.
ADD $PBF /app/nominatim/$PBF

# Faster and loose for loading.
#RUN /root/postgres_install_time.sh

# Run nominatim setup.
RUN service postgresql start && \
    pg_dropcluster --stop 9.3 main && \
    service postgresql start && \
    pg_createcluster --start -e UTF-8 9.3 main && \
    service postgresql start && \
    sudo -u postgres createuser -s nominatim && \
    sudo -u postgres createuser -SDR www-data && \
    service postgresql start && \
    su nominatim -c './utils/setup.php --osm-file $PBF --all --threads 2' && \
    ./utils/setup.php --create-website /var/www/nominatim

# Now, safety first.
RUN /root/postgres_post_install.sh

RUN service postgresql stop

EXPOSE 80

CMD /root/start.sh

