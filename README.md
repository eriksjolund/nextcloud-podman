# nextcloud-podman

Demo of running nextcloud with rootless podman by using these containers

| image | comment |
| --    | --      |
| docker.io/library/mariadb:latest | |
| docker.io/library/redis:latest | |
| localhost/nginx | built from https://github.com/eriksjolund/nextcloud-docker/tree/podman-experiment/.examples/docker-compose/insecure/mariadb/fpm/web |
| localhost/nextcloud | built from [Docker.nextcloud](Dockerfile.nextcloud) (based on docker.io/library/nextcloud:fpm) |

__status:__ experimental

The text `Nextcloud` can be seen when running curl:

```
$ curl -s localhost:8080  | grep title
		<title>
			Nextcloud		</title>
```

Tested with podman 4.7.0.

## Installation

Run nextcloud

```
mkdir -p ~/.config/containers/systemd
mkdir -p ~/.config/systemd/user

podman create network podman2

git clone https://github.com/eriksjolund/nextcloud-docker
git checkout podman-experiment
podman build -t nginx nextcloud-docker/.examples/docker-compose/insecure/mariadb/fpm/web

git clone https://github.com/eriksjolund/nextcloud-podman
podman build -t nextcloud -f nextcloud-podman/Dockerfile.nextcloud nextcloud-podman

cp nextcloud-podman/mariadb.container ~/.config/containers/systemd
cp nextcloud-podman/nextcloud.container ~/.config/containers/systemd
cp nextcloud-podman/nginx.container ~/.config/containers/systemd
cp nextcloud-podman/nginx.socket ~/.config/systemd/user

# create data directory that will be bind-mounted by the mariadb container
mkdir ~/mariadb_data

# create data directory that will be bind-mounted by the nginx container and the nextcloud container
mkdir ~/shared_html

systemctl --user daemon-reload
systemctl enable --now redis.service
systemctl enable --now mariadb.service
systemctl enable --now nextcloud.service
systemctl enable --now nginx.socket
```
