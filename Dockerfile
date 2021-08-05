FROM nginx:1.21 as builder

MAINTAINER andy <andycrusoe@gmail.com>

# set label
LABEL maintainer="andy"
ENV NGX_CACHE_PURGE_VERSION=2.5.1
ENV NGX_BROTLI_VERSION=v1.0.0rc

# Install basic packages and build tools
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      wget \
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
    wget https://github.com/google/ngx_brotli/archive/refs/tags/$NGX_BROTLI_VERSION.tar.gz \
         -O ngx_brotli-$NGX_BROTLI_VERSION.tar.gz && \
    tar -xf nginx-$NGINX_VERSION.tar.gz && \
    mv nginx-$NGINX_VERSION nginx && \
    rm nginx-$NGINX_VERSION.tar.gz && \
    tar -xf ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    mv ngx_cache_purge-$NGX_CACHE_PURGE_VERSION ngx_cache_purge && \
    rm ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    tar -xf ngx_brotli-$NGX_BROTLI_VERSION.tar.gz && \
    mv ngx_brotli-$NGX_BROTLI_VERSION ngx_brotli && \
    rm ngx_brotli-$NGX_BROTLI_VERSION.tar.gz
    
# configure and build
RUN cd /tmp/nginx && \
    BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
    /bin/sh -c "./configure ${BASE_CONFIGURE_ARGS} --add-module=/tmp/ngx_cache_purge --add-dynamic-module=/tmp/ngx_brotli" && \
    make && make install && \
    rm -rf /tmp/nginx*
    
FROM nginx:1.21
# Extract the dynamic modules from the builder image
COPY --from=builder /usr/local/nginx/modules/ngx_http_brotli_filter_module.so /usr/local/nginx/modules/ngx_http_brotli_filter_module.so
COPY --from=builder /usr/local/nginx/modules/ngx_http_brotli_static_module.so /usr/local/nginx/modules/ngx_http_brotli_static_module.so
COPY --from=builder /usr/local/nginx/modules/ngx_http_cache_purge_module.so /usr/local/nginx/modules/ngx_http_cache_purge_module.so
