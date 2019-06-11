# Debian (slim) VNC

A lightweight (569 MB) personal Linux workstation based on [Debian](https://hub.docker.com/_/debian)-slim. Provides VNC and SSH services.

*Ramon Solano (<ramon.solano at gmail.com>)*

**Last update**: Jun/11/2019     
**Base image**: Debian 9.9 (stretch-20190610)


## Main packages

* xvfd    : X virtual framebuffer (in-memory X display server)
* xfce4   : Graphic desktop environment
* x11vnc  : X vnc server
* sshd    : SSH server

## Users

User/pwd:

* root / debian
* debian / debian (sudoer)

## To build the image from the `Dockerfile` (optional)

If you want to customize the image or use it for creating a new one, you can download (clone) it from the [corresponding github repository](https://github.com/rwildcat/docker_debian-slim-vnc). 

```sh
# clone git repository
$ git clone https://github.com/rwildcat/docker_debian-slim-vnc.git

# build image
$ cd docker_debian-slim-vnc
$ docker build -t rsolano/debian-slim-vnc .
```

Otherwise, you can *pull it* from its [docker hub repository](https://cloud.docker.com/u/rsolano/repository/docker/rsolano/debian-slim-vnc):

```
$ docker pull rsolano/debian-slim-vnc
```

**NOTE:** If yu run the image without downloading it first (*e.g.* `$docker run ..`), Docker will *pull it* from the docker repository for you if it does not exist in your local image repository.

## To run the container

To run the container, you can just issue the `$ docker run `   command. The image will be first *pulled* if it required:

```sh
$ docker run [-it] [--rm] [--detach] [-h HOSTNAME] -p LVNCPORT:5900 -p LSSHPORT:22 [-e XRES=1280x800x24] [-v LDIR:DIR] rsolano/debian-slim-vnc
```

where:

* `LVNCPORT`: Localhost VNC port to connect to (e.g. 5900 for display :0).

* `LSSHPORT`: local SSH port to connect to (e.g. 2222, as *well known ports* (those below 1024) may be reserved by your system).

* `XRES`: Screen resolution and color depth.

* `LDIR:DIR`: Local directory to mount on container. `LDIR` is the local directory to export; `DIR` is the target dir on the container.  Both sholud be specified as absolute paths. For example: `-v $HOME/worskpace:/home/debian/workspace`.

### Examples

* Run image, keep terminal open (`-it` : interactive terminal session); remove container from memory once finished the container (`--rm`); map VNC to 5900 (`-p 5900:5900`) and SSH to 2222 (`-p 2222:22`):

	```sh
	$ docker run -it --rm -p 5900:5900 -p 2222:22 rsolano/debian-slim-vnc
	```

* Run image, keep *console* open (non-interactive terminal session); remove container from memory once finished the container; map VNC to 5900 and SSH to 2222; mount local `$HOME/workspace` on container's `/home/debian/workspace` (`-v $HOME/...`):

	```sh
	$ docker run --rm -p 5900:5900 -p 2222:22 -v $HOME/workspace:/home/debian/workspace rsolano/debian-slim-vnc
	```

* Run image, detach to background (`--detach`, or just `-d`) and keep running in memory (control returns to user immediately); map VNC to 5900 and SSH to 2222; change screen resolution to 1200x700x24 (`XRES=...`)

	```sh
	$ docker run --detach -p 5900:5900 -p 2222:22 -e XRES=1200x700x24 rsolano/debian-slim-vnc
	```

#### To run a ***secured*** VNC session

This container is intended to be used as a *personal* graphic workstation, running in your local Docker engine. For this reason, no encryption for VNC is provided. 

If you need to have an encrypted connection as for example for running this image in a remote host (*e.g.* AWS, Google Cloud, etc.), the VNC stream can be encrypted through a SSH connection:

```sh
$ ssh [-p SSHPORT] [-f] -L 5900:REMOTE:5900 debian@REMOTE sleep 60
```
where:

* `SSHPORT`: SSH port specified when container was launched. If not specified, port 22 is used.

* `-f`: Request SSH to go to background afte the command is issued

* `REMOTE`: IP or qualified name for your remote container

This example assume the SSH connection will be terminated after 60 seconds if no VNC connection is detected, or just after the VNC connection was finished.

EXAMPLES:

* Establish a secured VNC session to the remote host 140.172.18.21, keep open a SSH terminal to the remote host. Map remote 5900 port to local 5900 port. Assume remote SSH port is 22:

	```sh
	$ ssh -L 5900:140.172.18.21:5900 debian@140.172.18.21
	```

* As before, but do not keep a SSH session open, but send the connecction to the background. End SSH channel if no VNC connection is made in 60 s, or after the VNC session ends:

	```sh
	$ ssh -f -L 5900:140.172.18.21:5900 debian@140.172.18.21 sleep 60
	```

Once VNC is tunneled through SSH, you can connect your VNC viewer to you specified localhot port (*e.g.* port 5900 as in this examples).


## To stop container

* If running an interactive session:

  * Just press `CTRL-C` in the interactive terminal.

* If running a non-interactive session:

  * Just press `CTRL-C` in the console (non-interactive) terminal.


* If running *detached* (background) session:

	1. Look for the container Id with `docker ps`:   
	
		```
		$ docker ps
		CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                          NAMES
		ac46f0cf41d1        rsolano/debian-slim-vnc   "/usr/bin/supervisor…"   58 seconds ago      Up 57 seconds       0.0.0.0:5900->5900/tcp, 0.0.0.0:2222->22/tcp   wizardly_bohr
		```

	2. Stop the desired container Id (ac46f0cf41d1 in this case):

		```sh
		$ docker stop ac46f0cf41d1
		```
		
 ## Container usage
 
1. First run the container as described above.

2. Connect to the running host (`localhost` if running in your computer):

	* Using VNC: 

		Connect to specified LVNCPORT (e.g. `localhost:0` or `localhost:5900`)
		 
	* Using SSH: 

		Connect to specified host (e.g. `localhost`) and SSHPORT (e.g. 2222) 
		
		```sh
		$ ssh -p 2222 debian@localhost
		```

## Additional files

    ./etc/supervisor.conf

### File contents:    

	[supervisord]
	nodaemon = true
	user = root
	#loglevel = debug
	
	[program:sshd]
	command = /usr/sbin/sshd -D
	
	[program:xvfb]
	command = /usr/bin/Xvfb :1 -screen 0 %(ENV_XRES)s
	priority=100
	
	[program:x11vnc]
	environment = DISPLAY=":1",XAUTHLOCALHOSTNAME="localhost"
	command=/usr/bin/x11vnc -repeat -xkb -noxrecord -noxfixes -noxdamage -wait 10 -shared -permitfiletransfer -tightfilexfer
	autorestart = true
	priority=200
	
	[program:startxfce4]
	environment=USER="debian",HOME="/home/debian",DISPLAY=":1"
	command=/usr/bin/startxfce4
	directory = /home/debian
	user=debian
	priority=300
