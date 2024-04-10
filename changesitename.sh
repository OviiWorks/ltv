#!/bin/bash

read -p "Mājaslapas adrese : " site_name

nginx_conf="config/nginx.conf"

if [ ! -f "$nginx_conf" ]; then
    echo "Nginx konfigurācijas fails netika atrasts!"
    exit 1
fi

sed -i "s/^ *server_name .*;$/    server_name $site_name;/g" "$nginx_conf"


echo "Vietnes nosaukums nomainīts uz $site_name"
