# The Problem

For a few projects, I wanted to do bulk geocoding. I didn't want to abuse the [OSM](https://www.openstreetmap.org/) servers; I didn't want to pay 50 cents per 1,000 requests on Google; and, I wanted to learn basic Docker. This project is a solution to all three problems. 


# Installation

```sh
git clone https://github.com/jbn/dockerized-nominatim.git
cd dockerized-nominatim

# Get your extract locally. In case there is a problem, 
# it's more polite than downloading it a few times. 
wget http://download.geofabrik.de/europe/monaco-latest.osm.pbf

docker build --build-arg PBF=monaco-latest.osm.pbf -t nominatim-monaco .
```

# Usage

```sh
docker run -p 8080:80 nominatim-monaco

docker-machine ip # => IP address if using docker-machine

google-chrome http://docker-ip:8080/nominatim/
```

Then, see the [API](http://wiki.openstreetmap.org/wiki/Nominatim#Search) for mechanical queries.

# Caveats

I am not a devops guy. Surely, there are better solutions. I based this code partially off of [nominatim-docker](https://github.com/helvalius/nominatim-docker/blob/master/Dockerfile). If that image doesn't work for you, use this one. But, I'd probably try that one first. 

