# [qBittorrent](https://github.com/qbittorrent/qBittorrent) and WireGuard

Docker container which runs [qBittorrent](https://github.com/qbittorrent/qBittorrent)-nox (headless) version 5.1.2 client while connecting to WireGuard with iptables killswitch to prevent IP leakage when the tunnel goes down.

# Specs and Features
* Base: Alpine Linux
* Supports amd64 and arm64 architectures.
* [qBittorrent](https://github.com/qbittorrent/qBittorrent) from the official Docker repo (qbittorrentofficial/qbittorrent-nox:5.1.2-1)
* Uses the Wireguard VPN software.
* IP tables killswitch to prevent IP leaking when VPN connection fails.
* Configurable UID and GID for config files and /downloads for qBittorrent.
* BitTorrent port 8999 exposed by default.
* Automatically restarts the qBittorrent process in the event of it crashing.
* Adds [VueTorrent](https://github.com/VueTorrent/VueTorrent) (alternate web UI) which can be enabled (or not) by the user.
* Works with Proton VPN's port forward VPN servers to automatically enable forwarding in your container, and automatically sets the connection port in qBittorrent to match the forwarded port.
* Provides optional support for [Cloudflare Access](https://developers.cloudflare.com/access/) to allow the ProtonVPN port forwarding to work when Cloudflare Access is enabled for the qBittorrent web UI.

# Documentation
All documentation is provided in the [wiki](https://github.com/tenseiken/docker-qbittorrent-wireguard/wiki).

# Issues
If you are having issues with this container, and you could not find a solution in the [wiki](https://github.com/tenseiken/docker-qbittorrent-wireguard/wiki), please submit an [issue](https://github.com/tenseiken/docker-qbittorrent-wireguard/issues) on GitHub.  
Please provide logs, Docker version and other information that can simplify reproducing the issue.  
If possible, always use the most up to date version of Docker, your operating system, kernel and the container itself. My time is finite, so support is always a best-effort basis.

# Credits
* [DyonR/docker-qBittorrentvpn](https://github.com/DyonR/docker-qbittorrentvpn)

This project originates from DyonR/docker-qbittorrentvpn, but forking wasn't possible because tenseiken/docker-qbittorrentvpn uses the fork already. I forked to tenseiken/docker-qbittorrentvpn to make some minor adjustments to the code in order to send a pull request to the original repo, but the PR was never accepted and the original project was archived. This new project drops the OpenVPN support since Wireguard is the superior option, and any VPN provider worth using offers Wireguard servers. I also dropped the option to just not use a VPN. If you don't wish to use a VPN, I highly recommend you make use of the [official qBittorrent repo](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox) instead of this one.

* [MarkusMcNugen/docker-qBittorrentvpn](https://github.com/MarkusMcNugen/docker-qBittorrentvpn)  
* [DyonR/jackettvpn](https://github.com/DyonR/jackettvpn)

DyonR/docker-qBittorrentvpn originates from MarkusMcNugen/docker-qBittorrentvpn, but forking was not possible since DyonR/jackettvpn uses the fork already.
