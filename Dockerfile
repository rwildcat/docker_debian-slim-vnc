# Updated on 2019-04-28
# R. Solano <ramon.solano@gmail.com>

FROM debian:buster-slim

# tzdata settings (to avoid install-time questions)
ENV TZ_AREA America
ENV TZ_CITY Mexico_City

RUN ln -fs /usr/share/zoneinfo/${TZ_AREA}/${TZ_CITY} /etc/localtime \
	&& apt-get update \
	&& apt-get -y install sudo supervisor openssh-server \
	xvfb x11vnc xfce4 xfce4-terminal  \
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
