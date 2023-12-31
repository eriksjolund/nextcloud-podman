# nextcloud-podman

Demo of running nextcloud with rootless podman by using these containers

| image | comment |
| --    | --      |
| docker.io/library/mariadb:latest | |
| docker.io/library/redis:latest | |
| localhost/nginx | built from https://github.com/eriksjolund/nextcloud-docker/tree/podman-experiment/.examples/docker-compose/insecure/mariadb/fpm/web |
| localhost/nextcloud | built from [Dockerfile.nextcloud](Dockerfile.nextcloud) (based on docker.io/library/nextcloud:fpm) |

__status:__ experimental

Tested with podman 4.7.0.

A minimal test to see that it's possible to log in worked:

1. `systemctl --user start mariadb.service`
2. `systemctl --user start redis.service`
3. `systemctl --user start nextcloud.service`
4. `systemctl --user start nginx.socket`
5. browse to http://localhost:8080
6. wait until the nextcloud web interface is shown. (Possibly reloading the webpage is required?). This step might take about 5 minutes.
7. fill in a username and a password in the _create admin account_ web form.
8. log in with the username and password.
9. check disk consumption in the bind-mounted directories _~/mariadb_data_ and _~/shared_html_
   ```
   $ podman unshare du -sh ~/mariadb_data
   190M	/var/home/test/mariadb_data
   $ podman unshare du -sh ~/shared_html
   630M	/var/home/test/shared_html
   $
   ```
10. check if all files and directories under _~/mariadb_data_ and _~/shared_html_ are owned by the regular user on the host
    ```
    $ uid=$(id -u)
    $ gid=$(id -g)
    $ find ~/mariadb_data -not -user $uid
    $ find ~/mariadb_data -not -group $gid
    $ find ~/shared_html -not -user $uid
    $ find ~/shared_html -not -group $gid
    $
    ```
    __result__: yes, files are owned by the regular user on the host

## Installation

```
mkdir -p ~/.config/containers/systemd
mkdir -p ~/.config/systemd/user

podman network create podman2

git clone https://github.com/eriksjolund/nextcloud-docker
git -C nextcloud-docker checkout podman-experiment
podman build -t nginx nextcloud-docker/.examples/docker-compose/insecure/mariadb/fpm/web

git clone https://github.com/eriksjolund/nextcloud-podman
podman build -t nextcloud -f nextcloud-podman/Dockerfile.nextcloud nextcloud-podman

cp nextcloud-podman/mariadb.container ~/.config/containers/systemd
cp nextcloud-podman/nextcloud.container ~/.config/containers/systemd
cp nextcloud-podman/nginx.container ~/.config/containers/systemd
cp nextcloud-podman/redis.service ~/.config/containers/systemd
cp nextcloud-podman/nginx.socket ~/.config/systemd/user

# create data directory that will be bind-mounted by the mariadb container
mkdir ~/mariadb_data

# create data directory that will be bind-mounted by the nginx container and the nextcloud container
mkdir ~/shared_html

systemctl --user daemon-reload
systemctl --user start redis.service
systemctl --user start mariadb.service
systemctl --user start nextcloud.service
systemctl --user start nginx.socket
```

### References

https://github.com/eriksjolund/podman-nginx-socket-activation
about: nginx, podman, socket activation

https://github.com/eriksjolund/podman-detect-option
about: `--userns keep-id:uid=$uid,gid=$gid`

https://github.com/containers/podman/discussions/20519
This project was created to see if it is possible to run nextcloud in multiple containers (nextcloud, mariadb, redis, nginx) with rootless podman and at the same
time only create files and directories that are owned by the regular user on the host. See the discussion for the starting point of the idea.
