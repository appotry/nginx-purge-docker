#!/bin/sh
NGINX_VERSION=1.21

docker build \
	--tag bloodstar/nginx-purge:$NGINX_VERSION \
	--force-rm \
	-f Dockerfile .
	
