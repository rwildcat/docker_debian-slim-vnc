# R. Solano <ramon.solano@gmail.com>

FROM debian:10.0-slim

# default screen size
ENV XRES=1280x800x24

# tzdata settings
ENV TZ_AREA America
ENV TZ_CITY Mexico_City

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& ln -fs /usr/share/zoneinfo/${TZ_AREA}/${TZ_CITY} /etc/localtime \
	&& apt-get update -q \
	&& apt-get install -qy sudo supervisor vim openssh-server apt-utils \
	xvfb x11vnc xfce4 xfce4-terminal xfce4-xkb-plugin xscreensaver \
	\
	# keep it slim
	&& apt-get remove -qy light-locker gnome-icon-theme gnome-themes-standard \
	gnome-accessibility-themes gnome-themes-standard-data \
	pulseaudio pulseaudio-utils \
	xserver-xorg-input-wacom xserver-xorg-legacy  xserver-xorg-video-amdgpu \
	xserver-xorg-video-ati xserver-xorg-video-intel \
	xserver-xorg-video-nouveau xserver-xorg-video-qxl xserver-xorg-video-radeon \
	xserver-xorg-video-vesa xserver-xorg-video-vmware \
	\
	# cleanup and fix
	&& apt-get autoremove -y \
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

# add my sys config files
ADD etc /etc

# customizations

# personal config files
ADD config/xfce4/terminal/terminalrc /home/debian/.config/xfce4/terminal/terminalrc
ADD config/xscreensaver /home/debian/.xscreensaver
RUN chown -R debian:debian /home/debian/.config /home/debian/.xscreensaver

# enable user aliases
RUN cd /home/debian \
	&& sed 's/#alias/alias/'< .bashrc > .bashrc \
	&& echo "alias lla='ls -al'" >> .bashrc

# ports
EXPOSE 22 5900

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
