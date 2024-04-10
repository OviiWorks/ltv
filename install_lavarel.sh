#!/bin/bash

username=$(whoami)
uid=$(id -u)

read -p "Ievadi aplikacijas nosaukumu: " appname

if [ -z "$appname" ]; then
    echo "Aplikācijas nosaukums nevar but tukšs."
    exit 1
fi
echo "Mysql lietotajs tiks izmantots esošais linux username."
echo "Ievadi mysql datubazes paroli:"
read -rs password_db
echo "Ievadi webhook adresi lai nosutitu docker engine un ubuntu versijas pēc sistēmu uzstādīšanas."
read -p "Webhook adrese: " webhookadress


cd ~
git clone https://github.com/laravel/laravel.git $appname
cd ~/$appname
sudo chown -R $username:$username ~/$appname
cd ~/$appname/
cp .env.example .env

# Definē jaunās vērtības priekš .env faila
new_values=(
    "DB_CONNECTION=mysql"
    "DB_HOST=db"
    "DB_PORT=3306"
    "DB_DATABASE=laravel"
    "DB_USERNAME=$username"
    "DB_PASSWORD=$password_db"
)

# Cikls cauri jaunajām vērtībām
for value in "${new_values[@]}"; do
    # noņem komentāru vērtībām kas atbilst definētajiem laukiem
    sed -i "s/^#* *${value%%=*}/# ${value%%=*}/" .env
    # Nomaina vērtību .env failā
    sed -i "s/^#* *${value%%=*}=.*/$value/" .env
done


cat << EOF > docker-compose.yml
version: '3'
services:

  #PHP Serviss
  app:
    build:
      args:
        user: $username
        uid: $uid
      context: .
      dockerfile: Dockerfile
    image: $username/php
    container_name: app
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./:/var/www
      - ./php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - app-network

  #Nginx Webserveris
  webserver:
    image: nginx:alpine
    container_name: webserver
    restart: unless-stopped
    tty: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./:/var/www
      - ./nginx/conf.d/:/etc/nginx/conf.d/
      - ./nginx-logs:/var/log/nginx
    networks:
      - app-network

  #MySQL Datubāze
  db:
    image: mysql:8.0
    container_name: db
    restart: unless-stopped
    tty: true
    env_file:
      - .env
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: \${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: \${DB_PASSWORD}
      MYSQL_PASSWORD: \${DB_PASSWORD}
      MYSQL_USER: \${DB_USERNAME}
    volumes:
      - dbdata:/var/lib/mysql/
      - ./mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - app-network

#Docker Tīkls
networks:
  app-network:
    driver: bridge
#Volumes
volumes:
  dbdata:
    driver: local

EOF
echo "Docker Compose fails izveidots."
cat << EOF > Dockerfile
FROM php:8.2-fpm

# Argumenti kas defineti docker-compose.yml failā.
ARG user
ARG uid

# Instalē nepieciešamās papildprogrammas
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Notīra cache atmiņu
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalē PHP paplašinājumus
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Lejuplādē jaunāko Composter
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Izveido sistēmas lietotāju lai varētu laist Composer un Artisan komandas
RUN useradd -G www-data,root -u "$uid" -d "/home/$username" "$username"
RUN mkdir -p /home/$username/.composer && \
    chown -R $username:$username /home/$username

WORKDIR /var/www

USER $username:$username
EOF
mkdir -p ~/$appname/nginx/conf.d
mkdir -p ~/$appname/mysql/conf.d
mkdir -p ~/$appname/php/conf.d
cp ~/lavarel/config/nginx.conf ~/$appname/nginx/conf.d/$appname.conf
cp ~/lavarel/config/mysql_my.cnf ~/$appname/mysql/my.cnf
cp ~/lavarel/config/php_local.ini ~/$appname/php/local.ini

cd ~/$appname/

echo "Tiek veidots aplikacijas konteineris"
docker-compose build app
echo "Startēju nepieciešamos konteinerus"
docker-compose up -d

containers=("webserver" "db" "app")

for container in "${containers[@]}"
do
    # Parbauda vai konteiners ir palaists
    if docker ps --format '{{.Names}}' | grep -q "$container"; then
        echo "$container: ok"
    else
        echo "$container: not running"
    fi
done

docker-compose exec app composer install
docker-compose exec app php artisan key:generate
sleep 5
docker-compose exec app php artisan migrate


# Dabon docker versiju un ubuntu versiju un nosuta caur webhook

docker_version=$(docker -v | awk '{print $3}' | cut -d',' -f1)
ubuntu_version=$(cat /etc/os-release | grep "VERSION_ID" | cut -d '"' -f 2)
webhook_url=$webhookadress

query_string="docker_version=${docker_version}&ubuntu_version=${ubuntu_version}"
curl -X POST -d "$query_string" "$webhook_url"

echo "Webhook ziņojums nosutits."
echo "Uzdevums izpildīts !"
