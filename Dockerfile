# qBittorrent, OpenVPN and WireGuard, qbittorrentvpn
FROM qbittorrentofficial/qbittorrent-nox:4.6.4-1

WORKDIR /opt

# Make directories
RUN mkdir -p /downloads /config/qBittorrent /etc/openvpn /etc/qbittorrent

# Download and extract VueTorrent
RUN apk --no-cache --update-cache update \
    && apk --no-cache --update-cache upgrade \
    && apk --no-cache --update-cache add \
	curl \
	unzip \
    && VUETORRENT_RELEASE=v2.7.2 \
    && curl -o /config/vuetorrent.zip -L "https://github.com/VueTorrent/VueTorrent/releases/download/${VUETORRENT_RELEASE}/vuetorrent.zip" \
    && cd /config \
	&& unzip vuetorrent.zip \
	&& apk del \
    curl \
	unzip

# Install WireGuard and some other dependencies some of the scripts in the container rely on.
RUN apk --no-cache --update-cache update \
    && apk --no-cache --update-cache add \
	bash \
	curl \
    dos2unix \
    iputils-ping \
    ipcalc \
    iptables \
	jq \
    kmod \
    moreutils \
    net-tools \
	libnatpmp \
    openresolv \
    openvpn \
    procps \
    wireguard-tools

# Remove src_valid_mark from wg-quick
RUN sed -i /net\.ipv4\.conf\.all\.src_valid_mark/d `which wg-quick`

VOLUME /config /downloads

ADD start.sh /
ADD qbittorrent/ /etc/qbittorrent/

RUN chmod +x /start.sh
RUN chmod +x /etc/qbittorrent/*.sh

EXPOSE 8080
EXPOSE 8999
EXPOSE 8999/udp
ENTRYPOINT ["/bin/bash", "/start.sh"]