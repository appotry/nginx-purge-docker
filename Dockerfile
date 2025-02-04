FROM nginx:stable as builder

MAINTAINER andy <andycrusoe@gmail.com>

# set label
LABEL maintainer="andy"
ENV NGX_CACHE_PURGE_VERSION=2.5.2
ENV NGX_BROTLI_VERSION=v1.0.0rc

# for local build
#ENV http_proxy http://192.168.0.105:1089
#ENV https_proxy http://192.168.0.105:1089

# Install basic packages and build tools
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      wget \
      git \
      flex \
      bison \
      libsodium23 \
      libsodium-dev \
      zlib1g-dev \
      build-essential \
      libssl-dev \
      libpcre3 \
      libpcre3-dev  \
      apache2-utils \
      ca-certificates \
      inetutils-ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download and extract sources
RUN NGINX_VERSION=`nginx -V 2>&1 | grep "nginx version" | awk -F/ '{ print $2}'` && \
    cd /tmp && \
    wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    wget https://github.com/nginx-modules/ngx_cache_purge/archive/refs/tags/$NGX_CACHE_PURGE_VERSION.tar.gz  \
         -O ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    tar -xf nginx-$NGINX_VERSION.tar.gz && \
    mv nginx-$NGINX_VERSION nginx && \
    rm nginx-$NGINX_VERSION.tar.gz && \
    tar -xf ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    mv ngx_cache_purge-$NGX_CACHE_PURGE_VERSION ngx_cache_purge && \
    rm ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz

#git clone https://github.com/nginx-modules/ngx_cache_purge.git && \

# Reuse same cli arguments as the nginx:alpine image used to build
RUN cd /tmp && \
    git clone https://github.com/google/ngx_brotli.git && \
    cd /tmp/ngx_brotli && git submodule update --init

RUN ls /usr/include/ut*

# https://docs.addesp.com/ngx_waf/zh-cn/
# RUN cd /tmp && \
#     git clone -b lts https://github.com/ADD-SP/ngx_waf.git && \
#     git clone https://github.com/troydhanson/uthash.git && \
#     git clone https://github.com/libinjection/libinjection.git && \
#     git clone https://github.com/jedisct1/libsodium.git --branch stable libsodium-src && \
#     cd /tmp/libsodium-src && \
#     ./configure --prefix=/tmp/nginx/libsodium --with-pic && \
#     make -j$(nproc) && make check -j $(nproc) && make install && \
#     export LIB_SODIUM=/tmp/nginx/libsodium && \
#     cp /tmp/libinjection /tmp/ngx_waf/inc/libinjection -r && \
#     cp /tmp/uthash/src/* /usr/include/ && \
#     cd /tmp/ngx_waf && make
   
       
# configure and build
# RUN cd /tmp/nginx && \
#     BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
#     /bin/sh -c "./configure ${BASE_CONFIGURE_ARGS} --add-module=/tmp/ngx_cache_purge --add-module=/tmp/ngx_brotli --add-module=/tmp/ngx_waf" && \
#     make && make install && \
#     rm -rf /tmp/nginx*

# configure and build
RUN cd /tmp/nginx && \
    BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
    /bin/sh -c "./configure ${BASE_CONFIGURE_ARGS} --add-module=/tmp/ngx_cache_purge --add-module=/tmp/ngx_brotli" && \
    make && make install && \
    rm -rf /tmp/nginx*
    
ENV http_proxy ""
ENV https_proxy ""
