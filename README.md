# [qBittorrent](https://github.com/qbittorrent/qBittorrent) and WireGuard

Docker container which runs [qBittorrent](https://github.com/qbittorrent/qBittorrent)-nox (headless) version 4.6.4 client while connecting to WireGuard with iptables killswitch to prevent IP leakage when the tunnel goes down.

# Docker Features
* Base: Alpine Linux
* [qBittorrent](https://github.com/qbittorrent/qBittorrent) from the official Docker repo (qbittorrentofficial/qbittorrent-nox:4.6.4-1)
* Uses the Wireguard VPN software.
* IP tables killswitch to prevent IP leaking when VPN connection fails.
* Configurable UID and GID for config files and /downloads for qBittorrent.
* BitTorrent port 8999 exposed by default.
* Automatically restarts the qBittorrent process in the event of it crashing.
* Adds [VueTorrent](https://github.com/VueTorrent/VueTorrent) (alternate web UI) which can be enabled (or not) by the user.
* Works with Proton VPN's port forward VPN servers to automatically enable forwarding in your container, and automatically sets the connection port in qBittorrent to match the forwarded port.

# Variables, Volumes, and Ports
## Environment Variables
| Variable | Required | Function | Example | Default |
|----------|----------|----------|----------|----------|
|`QBT_LEGAL_NOTICE`| Yes | Required by qBittorrent, indicates that you accept their [legal notice](https://github.com/qbittorrent/qBittorrent/blob/56667e717b82c79433ecb8a5ff6cc2d7b315d773/src/app/main.cpp#L320-L323). |`QBT_LEGAL_NOTICE=confirm`||
|`LAN_NETWORK`| Yes (at least one) | Comma delimited local Network's with CIDR notation |`LAN_NETWORK=192.168.0.0/24,10.10.0.0/24`||
|`ENABLE_SSL`| No | Let the container handle SSL (yes/no/ignore)? |`ENABLE_SSL=yes`|`ignore`|
|`NAME_SERVERS`| No | Comma delimited name servers |`NAME_SERVERS=1.1.1.1,1.0.0.1`|`1.1.1.1,1.0.0.1`|
|`PUID`| Yes | UID applied to /config files and /downloads |`PUID=99`||
|`PGID`| Yes | GID applied to /config files and /downloads  |`PGID=100`||
|`UMASK`| No | |`UMASK=002`|`002`|
|`HEALTH_CHECK_HOST`| No |This is the host or IP that the healthcheck script will use to check an active connection|`HEALTH_CHECK_HOST=one.one.one.one`|`one.one.one.one`|
|`HEALTH_CHECK_INTERVAL`| No |This is the time in seconds that the container waits to see if the internet connection still works (check if VPN died)|`HEALTH_CHECK_INTERVAL=300`|`300`|
|`HEALTH_CHECK_SILENT`| No |Set to `1` to supress the 'Network is up' message. Defaults to `1` if unset.|`HEALTH_CHECK_SILENT=1`|`1`|
|`HEALTH_CHECK_AMOUNT`| No |The amount of pings that get send when checking for connection.|`HEALTH_CHECK_AMOUNT=10`|`1`|
|`RESTART_CONTAINER`| No |Set to `no` to **disable** the automatic restart when the network is possibly down.|`RESTART_CONTAINER=yes`|`yes`|
|`ADDITIONAL_PORTS`| No |Adding a comma delimited list of ports will allow these ports via the iptables script.|`ADDITIONAL_PORTS=1234,8112`||
|`ENABLEPROTONVPNPORTFWD` | No | Enables Proton VPN port forwarding logic. 1 to enable, 0 to disable. | `ENABLEPROTONVPNPORTFWD=1` | 0 |
|`WEBUI_URL` | Only if port fwd enabled | Allows the script to use the WebUI API to set the forwarded port automatically. | `WEBUI_URL=https://webui.domain.com` / `WEBUI_URL=http://192.168.1.17` ||
|`WEBUI_USER` | Only if port fwd enabled | Allows the script to use the WebUI API to set the forwarded port automatically. | `WEBUI_USER=admin` ||
|`WEBUI_PASS` | Only if port fwd enabled | Allows the script to use the WebUI API to set the forwarded port automatically. | `WEBUI_PASS=adminadmin` ||
|`TZ` | No | Sets the time zone in the container so that log date/time will match your local date/time. | `TZ=America/New_York' ||

## Volumes
| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | qBittorrent, WireGuard and OpenVPN config files | `/your/config/path/:/config`|
| `downloads` | No | Default downloads path for saving downloads | `/your/downloads/path/:/downloads`|

## Ports
| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `8080` | TCP | Yes | qBittorrent WebUI | `8080:8080`|
| `8999` | TCP | Yes | qBittorrent TCP Listening Port | `8999:8999`|
| `8999` | UDP | Yes | qBittorrent UDP Listening Port | `8999:8999/udp`|

# Access the WebUI
Access https://IPADDRESS:PORT from a browser on the same network. (for example: https://192.168.0.90:8080)

## Default Credentials

| Credential | Default Value |
|----------|----------|
|`username`| `admin` |
|`password`| `adminadmin` |

# How to use WireGuard 
Drop a .conf file from your VPN provider into /config/wireguard and start the container. The file must have the name `wg0.conf`, or it will fail to start.

## WireGuard IPv6 issues
If you use WireGuard and also have IPv6 enabled, it is necessary to add the IPv6 range to the `LAN_NETWORK` environment variable.  
Additionally the parameter `--sysctl net.ipv6.conf.all.disable_ipv6=0` also must be added to the `docker run` command.

## Proton VPN Port Forwarding with Wireguard
If you use Proton VPN as your VPN provider, they offer a feature called port forwarding that will improve your connectability from peers in the swarm. This works by running a script on a loop in the background that periodically refreshes your port forward. That's necessary because they have to be set with an expiration time, even though we don't want it to expire while our client is running. We don't get to choose the port that's going to be forwarded (that is handled by Proton VPN), and it can change periodically, so we need to be able to change the listen port in qBittorrent in the event of a change. In order to update the listen port in qBittorrent, an authenticated API call to your local qBittorrent instance is required. If you want to have this functionality enabled, you can do the following:

- Use your Proton VPN account to acquire a Wireguard config file for one of their port-forwarding-enabled servers. These are paid servers--the free ones do not support it. Save this config file as wg0.conf in the Wireguard config directory just like you would any other Wireguard config file.
- Set the `ENABLEPROTONVPNPORTFWD` environment variable in your container to 1.
- Set the `WEBUI_URL` environment variable in your container to the URL you use to access your qBittorrent web UI. This can be the local IP (ex: http://192.168.1.17) or a public URL if you have one (ex: https://qbittorrent.mydomain.com). As long as the container can reach this URL over its network, it's fine.
- Set the `WEBUI_USER` environment variable in your container to the username you use to authenticate with your qBittorrent web UI.
- Set the `WEBUI_PASS` environment variable in your container to the password you use to authenticate with your qBittorrent web UI.

With all of that set up, port forwarding will be automatically established for you, and the listen port in qBittorrent will be set automatically.

# PUID/PGID
User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```

# Run Container from Docker Hub
The container is available from the Docker Hub and this is the simplest way to get it. Alternatively, you can clone this repo and build the image yourself if you want.
The following is a run command with the minimum required arguments. Please refer to the "Variables, Volumes, and Ports" section for more info about additional features.

```
$ docker run  -d \
              -v /your/config/path/:/config \
              -v /your/downloads/path/:/downloads \
              -e "QBT_LEGAL_NOTICE=confirm" \
              -e "PUID=1234" \
              -e "PGID=123" \
              -e "LAN_NETWORK=192.168.0.0/24" \
              -p 8080:8080 \
              --cap-add NET_ADMIN \
              --sysctl "net.ipv4.conf.all.src_valid_mark=1" \
              --restart unless-stopped \
              --name qbittorrent-wireguard \
              tenseiken/qbittorrent-wireguard:latest
```

If you prefer to use docker-compose instead of docker run, you can use the Docker-Compose.yml file to get started. It only has the required configuration (as with the docker run command above), but it will get you started.

# Using VueTorrent
If you'd like to use [VueTorrent](https://github.com/VueTorrent/VueTorrent), do the following in your web UI once it's up and running:

- Click the "Settings" gear icon.
- Click the "Web UI" tab.
- Check the box for "Use alternative Web UI".
- Set the "Files location" text box to: `/etc/vuetorrent`
- Click "Save".
- The page will refresh and load the VueTorrent web UI. 
- Log in with your normal web UI credentials.

# Issues
If you are having issues with this container please submit an issue on GitHub.  
Please provide logs, Docker version and other information that can simplify reproducing the issue.  
If possible, always use the most up to date version of Docker, your operating system, kernel and the container itself. Support is always a best-effort basis.

# Credits
* [DyonR/docker-qBittorrentvpn](https://github.com/DyonR/docker-qbittorrentvpn)

This project originates from DyonR/docker-qbittorrentvpn, but forking wasn't possible because tenseiken/docker-qbittorrentvpn uses the fork already. I forked to tenseiken/docker-qbittorrentvpn to make some minor adjustments to the code in order to send a pull request to the original repo, but the PR was never accepted and the original project was archived. This new project drops the OpenVPN support since Wireguard is the superior option, and any VPN provider worth using offers Wireguard servers. I also dropped the option to just not use a VPN. If you don't wish to use a VPN, I highly recommend you make use of the [official qBittorrent repo](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox) instead of this one.

* [MarkusMcNugen/docker-qBittorrentvpn](https://github.com/MarkusMcNugen/docker-qBittorrentvpn)  
* [DyonR/jackettvpn](https://github.com/DyonR/jackettvpn)

DyonR/docker-qBittorrentvpn originates from MarkusMcNugen/docker-qBittorrentvpn, but forking was not possible since DyonR/jackettvpn uses the fork already.
