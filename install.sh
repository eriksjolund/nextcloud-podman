#!/bin/bash

set -o errexit
set -o nounset

port=$1

if ! [[ $port =~ ^[0-9]+$ ]]; then
  echo "error: port argument is not a number" >&2
  exit 1 
fi

# create data directory that will be bind-mounted by the nginx container and the nextcloud container
mkdir -p ~/nextcloud-data/shared_html

# create data directory that will be bind-mounted by the mariadb container
mkdir -p ~/nextcloud-data/mariadb_data
touch ~/nextcloud-data/redis-session.ini

if [ ! -f  ~/nextcloud-data/nginx.conf ]; then
  tmpdir=$(mktemp -d)
  (cd $tmpdir && git clone https://github.com/nextcloud/docker.git)
  cat $tmpdir/docker/.examples/docker-compose/insecure/mariadb/fpm/web/nginx.conf \
    | sed "s/127.0.0.1:9000/app:9000/g" | sed "s/listen 80;/listen ${port};/g" > ~/nextcloud-data/nginx.conf
fi

mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/containers/systemd

for i in  mynet.network mariadb.container  nextcloud.container  nginx.container  nginx.socket  redis.container; do
  cp $i  ~/.config/containers/systemd/
done

cat nginx.socket.in | port=$port envsubst > ~/.config/systemd/user/nginx.socket

systemctl --user daemon-reload
systemctl --user start mynet-network.service

systemctl --user stop redis.service
systemctl --user stop mariadb.service
systemctl --user stop nextcloud.service
systemctl --user stop nginx.service
systemctl --user stop nginx.socket

systemctl --user reset-failed redis.service
systemctl --user reset-failed mariadb.service
systemctl --user reset-failed nextcloud.service
systemctl --user reset-failed nginx.socket

systemctl --user start redis.service
systemctl --user start mariadb.service
systemctl --user start nextcloud.service
systemctl --user start nginx.socket
