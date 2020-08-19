FROM debian:10.5-slim

# default screen size
ENV XRES=1280x800x24

# tzdata settings
ENV TZ_AREA=Etc
ENV TZ_CITY=UTC

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -q \
	&& apt-get install -qy --no-install-recommends \
	apt-utils sudo supervisor vim openssh-server \
	xserver-xorg xvfb x11vnc dbus-x11 \
	xfce4 xfce4-terminal xfce4-xkb-plugin  \
	\
	# fix LC_ALL: cannot change locale (en_US.UTF-8)
	locales \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& locale-gen en_US.UTF-8 \
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

# user config files
ADD config/gtkrc-2.0 /home/debian/.gtkrc-2.0
ADD config/xfce4/terminal/terminalrc /home/debian/.config/xfce4/terminal/terminalrc
ADD config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/debian/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

# TZ, aliases
RUN cd /home/debian \
	&& echo 'export TZ=/usr/share/zoneinfo/$TZ_AREA/$TZ_CITY' >> .bashrc \
	&& sed -i 's/#alias/alias/' .bashrc  \
	&& echo "alias lla='ls -al'" 		>> .bashrc \
	&& echo "alias llt='ls -ltr'"  		>> .bashrc \
	&& echo "alias llta='ls -altr'" 	>> .bashrc \
	&& echo "alias llh='ls -lh'" 		>> .bashrc \
	&& echo "alias lld='ls -l|grep ^d'" >> .bashrc \
	&& echo "alias hh=history" 			>> .bashrc \
	&& echo "alias hhg='history|grep -i" '"$@"' "'" >> .bashrc
	
# set owner
RUN chown -R debian:debian /home/debian/.*

# ports
EXPOSE 22 5900

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
