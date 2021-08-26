## [配置使用参考](https://hub.docker.com/_/nginx)

ARM64, ARMV7, AMD64 全平台支持添加

# 增加方便且高性能的 Nginx 防火墙模块 [ngx_waf](https://github.com/ADD-SP/ngx_waf)
```nginx
waf on; # 是否启用模块
waf_rule_path /www/server/nginx/src/ngx_waf/assets/rules/; # 模块规则
waf_mode STD !CC; # 启用普通模式并关闭CC防护
waf_cache capacity=50; # 缓存配置
waf_under_attack on uri=/under-attack.html; # 配置5秒盾
```
把测试用的5秒盾html文件复制到你的站点的根目录下
```
wget https://raw.githubusercontent.com/ADD-SP/ngx_waf/master/assets/under-attack.html -o /www/wwwroot/rn.vsvs.xyz
```

# 增加brotli 支持
在nginx配置文件中增加
```yaml
    brotli on;
    brotli_comp_level 6; 
    brotli_types
        text/css
        text/plain
        text/javascript
        application/javascript
        application/json
        application/x-javascript
        application/xml
        application/xml+rss
        application/xhtml+xml
        application/x-font-ttf
        application/x-font-opentype
        application/vnd.ms-fontobject
        image/svg+xml
        image/x-icon
        application/rss+xml
        application/atom_xml
        image/jpeg
        image/gif
        image/png
        image/icon
        image/bmp
        image/jpg;

```

# 增加 CA 证书 支持
在 docker compose 中映射ca文件
```
    volumes:
      - ${USERDIR}/nginx/certs/ca.crt:/usr/local/share/ca-certificates/ca.crt
```
然后执行
docker exec -it [docker name] update-ca-certificates --fresh


# 增加htpasswd 支持
例子：
docker exec -it [docker name] htpasswd -c /[path to nginx]/conf.d/cron2.htpasswd [user name]
```
        # To add basic authentication to v2 use auth_basic setting.
        #这个是提示信息
        auth_basic "Please input password";
        #存放密码文件的路径
        auth_basic_user_file /etc/nginx/conf.d/cron.htpasswd;
```


## docker compose
```
  nginxweb:
    image: bloodstar/nginx-purge
    container_name: "nginxweb"
    hostname: nginxweb
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      # ying she zhu ji wang zhan mu lu
      - ${USERDIR}/nginx/conf.d:/etc/nginx/conf.d:ro
      - ${USERDIR}/nginxproxy/certs:/etc/nginx/certs:ro
      - ${USERDIR}/nginx/nginx.conf:/etc/nginx/nginx.conf:ro

```


Sample configuration (same location syntax)
===========================================
    http {
        proxy_cache_path  /tmp/cache  keys_zone=tmpcache:10m;

        server {
            location / {
                proxy_pass         http://127.0.0.1:8000;
                proxy_cache        tmpcache;
                proxy_cache_key    $uri$is_args$args;
                proxy_cache_purge  PURGE from 127.0.0.1;
            }
        }
    }


Sample configuration (separate location syntax)
===============================================
    http {
        proxy_cache_path  /tmp/cache  keys_zone=tmpcache:10m;

        server {
            location / {
                proxy_pass         http://127.0.0.1:8000;
                proxy_cache        tmpcache;
                proxy_cache_key    $uri$is_args$args;
            }

            location ~ /purge(/.*) {
                allow              127.0.0.1;
                deny               all;
                proxy_cache_purge  tmpcache $1$is_args$args;
            }
        }
    }




About
=====
`ngx_cache_purge` is `nginx` module which adds ability to purge content from
`FastCGI`, `proxy`, `SCGI` and `uWSGI` caches.


Sponsors
========
Work on the original patch was fully funded by [yo.se](http://yo.se).


Status
======
This module is production-ready.


Configuration directives (same location syntax)
===============================================
fastcgi_cache_purge
-------------------
* **syntax**: `fastcgi_cache_purge on|off|<method> [from all|<ip> [.. <ip>]]`
* **default**: `none`
* **context**: `http`, `server`, `location`

Allow purging of selected pages from `FastCGI`'s cache.


proxy_cache_purge
-----------------
* **syntax**: `proxy_cache_purge on|off|<method> [from all|<ip> [.. <ip>]]`
* **default**: `none`
* **context**: `http`, `server`, `location`

Allow purging of selected pages from `proxy`'s cache.


scgi_cache_purge
----------------
* **syntax**: `scgi_cache_purge on|off|<method> [from all|<ip> [.. <ip>]]`
* **default**: `none`
* **context**: `http`, `server`, `location`

Allow purging of selected pages from `SCGI`'s cache.


uwsgi_cache_purge
-----------------
* **syntax**: `uwsgi_cache_purge on|off|<method> [from all|<ip> [.. <ip>]]`
* **default**: `none`
* **context**: `http`, `server`, `location`

Allow purging of selected pages from `uWSGI`'s cache.


Configuration directives (separate location syntax)
===================================================
fastcgi_cache_purge
-------------------
* **syntax**: `fastcgi_cache_purge zone_name key`
* **default**: `none`
* **context**: `location`

Sets area and key used for purging selected pages from `FastCGI`'s cache.


proxy_cache_purge
-----------------
* **syntax**: `proxy_cache_purge zone_name key`
* **default**: `none`
* **context**: `location`

Sets area and key used for purging selected pages from `proxy`'s cache.


scgi_cache_purge
----------------
* **syntax**: `scgi_cache_purge zone_name key`
* **default**: `none`
* **context**: `location`

Sets area and key used for purging selected pages from `SCGI`'s cache.


uwsgi_cache_purge
-----------------
* **syntax**: `uwsgi_cache_purge zone_name key`
* **default**: `none`
* **context**: `location`

Sets area and key used for purging selected pages from `uWSGI`'s cache.

Testing
=======
`ngx_cache_purge` comes with complete test suite based on [Test::Nginx](http://github.com/agentzh/test-nginx).

You can test it by running:

`$ prove`



# Nginx Compiled with ``ngx_cache_purge`` Module

This image is based on the official ``nginx:mainline`` ([see on Dockehub](https://hub.docker.com/_/nginx/)) and recompiled with the same configure options from vanilla nginx sources with addition of ``--add-module=ngx-cache-purge``.

[The fork](https://github.com/nginx-modules/ngx_cache_purge) of the [original FRiCLE's module](http://labs.frickle.com/nginx_ngx_cache_purge/) is used, which...

* is compatible with modern nginx
* supports purging by partial keys (``*`` at the end) (see [release notes](https://github.com/nginx-modules/ngx_cache_purge/releases))
