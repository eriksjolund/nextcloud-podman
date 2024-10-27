# nextcloud-podman

Demo of running nextcloud with rootless podman by using these containers

| image |
| --    |
| docker.io/library/mariadb:latest |
| docker.io/library/redis:latest |
| docker.io/library/nginx:alpine |
| docker.io/library/nextcloud:fpm |

Data is stored in bind mounted volumes under the directory _~/nextcloud-data_.
All files and directories have the ownership of the regular user on the host.
No pods are used. All containers are running in a custom network.
Nginx is configured to use [_socket activation_](https://github.com/eriksjolund/podman-nginx-socket-activation/).

__status:__ experimental

> [!WARNING]
> This guide configures nginx to use HTTP.
> HTTP requests and responses are sent in plaintext to the web browser.
> This is insecure. For real production use cases, you need to configure nginx to use HTTPS.

Tested with podman 5.3.0-RC1

A minimal test to see that it's possible to log in worked:

1. `sudo useradd test`
1. `sudo machinectl shell --uid=test`
1. `git clone https://github.com/eriksjolund/nextcloud-podman.git`
1. `cd nextcloud-podman`
1. Run command
   ```
   bash install.sh 8080
   ```
   The number chosen specifies the port.
   The command might take a few minutes before it returns because pulling _docker.io/library/nextcloud:fpm_
   can take a while.
1. In a web browser go to http://localhost:8080
1. Wait until the nextcloud web interface is shown. (Possibly reloading the webpage is required?). This step might take about 5 minutes.
1. Fill in a username and a password in the _create admin account_ web form.
1. Log in with the username and password.
1. Check disk consumption in the bind-mounted directories _~/nextcloud-data_
   ```
   $ podman unshare du -sh ~/nextcloud-data/
   883M	/var/home/test/nextcloud-data/
   $
   ```
1. Verify that all files and directories under _~/nextcloud-data_ are owned by the regular user on the host
    ```
    $ podman unshare find ~/nextcloud-data -not -user 0
    $ podman unshare find ~/nextcloud-data -not -group 0
    $
    ```
    __result__: yes, all files and directories under _~/nextcloud-data_ are owned by the regular user on the host

### References

https://github.com/eriksjolund/podman-nginx-socket-activation
about: nginx, podman, socket activation

https://github.com/eriksjolund/podman-detect-option
about: `--userns keep-id:uid=$uid,gid=$gid`

https://github.com/containers/podman/discussions/20519
This project was created to see if it is possible to run nextcloud in multiple containers (nextcloud, mariadb, redis, nginx) with rootless podman and at the same
time only create files and directories that are owned by the regular user on the host. See the discussion for the starting point of the idea.
