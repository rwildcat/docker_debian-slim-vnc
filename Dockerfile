# Updated on 2019-05-11
# Debian 9.9 (stretch-20190506-slim)
# R. Solano <ramon.solano@gmail.com>

FROM debian:9.9-slim

# tzdata settings (to avoid install-time questions)
ENV TZ_AREA America
ENV TZ_CITY Mexico_City

# update and install software
RUN ln -fs /usr/share/zoneinfo/${TZ_AREA}/${TZ_CITY} /etc/localtime \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update -q \
	&& apt-get install -qy sudo supervisor openssh-server apt-utils \
	xvfb x11vnc xfce4 xfce4-terminal xfce4-xkb-plugin \
	\
	# keep it slim
	&& apt-get remove -qy gnome-icon-theme gnome-themes-standard \
	gnome-accessibility-themes gnome-themes-standard-data \
	pulseaudio pulseaudio-utils \
	xserver-xorg-input-wacom xserver-xorg-legacy  xserver-xorg-video-amdgpu \
	xserver-xorg-video-ati xserver-xorg-video-fbdev xserver-xorg-video-intel \
	xserver-xorg-video-nouveau xserver-xorg-video-qxl xserver-xorg-video-radeon \
	xserver-xorg-video-vesa xserver-xorg-video-vmware \
	\
	# cleanup and fix
	&& apt autoremove -qy \
	&& apt-get --fix-broken install \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# required preexisting dirs
RUN mkdir /run/sshd

# users and groups
RUN echo "root:debian" | /usr/sbin/chpasswd \
    && useradd -m debian -s /bin/bash \
    && echo "debian:debian" | /usr/sbin/chpasswd \
    && echo "debian    ALL=(ALL) ALL" >> /etc/sudoers 

# default screen size
ENV XRES=1280x800x24

# add my config files
ADD etc /etc

# ports
EXPOSE 22 5900

# customizations
# enable user aliases
RUN cd /home/debian \
	&& sed 's/#alias/alias/'< .bashrc > .bashrc \
	&& echo "alias lla='ls -al'" >> .bashrc

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
