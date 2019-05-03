# Debian (slim) VNC

A lightweight (495 MB) Linux workstation based on [Debian](https://hub.docker.com/_/debian)-slim. Provides VNC and SSH services.

*Ramon Solano <<ramon.solano@gmail.com>>*

**Last update**: May/03/2019    
**Base image**: Debian 9.8 (stretch) slim

## Main packages

* xvfd    : X virtual framebuffer (in-memory X display server)
* xfce4   : Graphic desktop environment
* x11vnc  : X vnc server
* sshd    : SSH server

## Users

User/pwd:

* root / debian
* debian / debian (sudoer)

## To build from `Dockerfile`

```sh
$ docker build -t rsolano/debian-slim-vnc .
```

## To run container

```sh
$ docker run [-it] [--rm] [--detach] [-h <HOSTNAME] -p <LVNCPORT>:5900 -p <LSSHPORT>:22 [-e XRES=1280x800x24] [-v LDIR:DIR] rsolano/debian-slim-vnc
```

where:

* `LVNCPORT`: Localhost VNC port to connect to (e.g. 5900 for display :0).

* `LSSHPORT`: local SSH port to connect to (e.g. 2222, as *well known ports* (those below 1024) may be reserved by your system).

* `XRES`: Screen resolution and color depth.

* `LDIR:DIR`: Local directory to mount on container. `LDIR` is the local directory to export; `DIR` is the target dir on the container.  Both sholud be specified as absolute paths. For example: `-v $HOME/worskpace:/home/debian/workspace`.

### Examples

* Run image, keep terminal open (interactive terminal session); remove container from memory once finished the container; map VNC to 5900 and SSH to 2222:

	```sh
	$ docker run -it --rm -p 5900:5900 -p 2222:22 rsolano/debian-slim-vnc
	```

* Run image, keep *console* open (non-interactive terminal session); remove container from memory once finished the container; map VNC to 5900 and SSH to 2222; mount local `$HOME/workspace` on container's `/home/debian/workspace`:

	```sh
	$ docker run --rm -p 5900:5900 -p 2222:22 -v $HOME/workspace:/home/debian/workspace rsolano/debian-slim-vnc
	```

* Run image, detach to background and keep running in memory (control returns to user immediately); map VNC to 5900 and SSH to 2222; change screen resolution to 1200x700x24

	```sh
	$ docker run --detach -p 5900:5900 -p 2222:22 -e XRES=1200x700x24 rsolano/debian-slim-vnc
	```

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
