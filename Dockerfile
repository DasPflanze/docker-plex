FROM lsiobase/xenial
MAINTAINER Stian Larsen, sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server" \
PLEX_INSTALL="https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu" \
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
PLEX_MEDIA_SERVER_INFO_DEVICE=docker \
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
PLEX_MEDIA_SERVER_USER=abc

# install packages
RUN \
 apt-get update && \
 apt-get install -y \
 	software-properties-common && \
 add-apt-repository ppa:stebbins/handbrake-releases && \
 apt-get update && \
 apt-get install -y \
 	git \
	handbrake-cli \
	ffmpeg \
	build-essential \
	libargtable2-dev \
	libavformat-dev \
	libsdl1.2-dev \
	avahi-daemon \
	dbus \
	unrar \
	wget && \

# install plex
 curl -o \
	/tmp/plexmediaserver.deb -L \
	"${PLEX_INSTALL}" && \
 dpkg -i /tmp/plexmediaserver.deb && \
 
 # get comchap/comcut
 cd / && \
 git clone https://github.com/BrettSheleski/comchap.git && \
 
 # get comskip
 cd /root && \
 git clone git://github.com/erikkaashoek/Comskip && \
 cd Comskip && \
 ./autogen.sh && \
 ./configure && \
 make && \
 cd /opt && \
 git clone https://github.com/ekim1337/PlexComskip.git && \
 cd Comskip && \

# change abc home folder to fix plex hanging at runtime with usermod
 usermod -d /app abc && \

# cleanup
 apt-get clean && \
 rm -rf \
	/etc/default/plexmediaserver \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp
VOLUME /config /transcode
