# Debian (slim) VNC

An headless *slim* (~680 MB) [Debian](https://hub.docker.com/_/debian)-based personal VNC workstation + SSH (no login manager).

X server is provided by [Xvfb](https://en.wikipedia.org/wiki/Xvfb), and Desktop environment provided by [Xfce](https://www.xfce.org) .

(C) Ramon Solano <ramon.solano@gmail.com>

### Contents

* xvfd    : X virtual framebuffer (in-memory X display server)
* xfce4   : Graphic desktop environment
* x11vnc  : X vnc server
* sshd    : Ssh server

### Users

* root/debian
* debian/debian (sudoer)

### To build

```sh
$ docker build -t rsolano/debian-slim-vnc .
```

### To run

```sh
$ docker run -it --rm -p <VNCPORT>:5900 -p <SSHPORT>:22 [-e XRES=1280x800x24] rsolano/debian-slim-vnc
```

*e.g.*

* Run and remove container from memory at end; mapping VNC to 5900 and SSH to 2222

	```sh
	$ docker run --rm -p 5900:5900 -p 2222:22 rsolano/debian-slim-vnc
	```

* Run and keep running in memory, mapping VNC to 5900 and SSH to 2222, resize to 1200x700x24

	```sh
	$ docker run --detach -p 5900:5900 -p 2222:22 -e XRES=1200x700x24 rsolano/debian-slim-vnc
	```

### To stop

* If running an interactive session:

	* Just press `CTRL-C` in the terminal.

* If running a non-interactive (*detached*) session:

	1. Look for the container Id:

		```bash
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                          NAMES
ac46f0cf41d1        rsolano/debian-slim-vnc   "/usr/bin/supervisor…"   58 seconds ago      Up 57 seconds       0.0.0.0:5900->5900/tcp, 0.0.0.0:2222->22/tcp   wizardly_bohr```

	2. Stop the desired container Id (ac46f0cf41d1 in this case):

		```bash
		$ docker stop ac46f0cf41d1
		```



		
 ### Usage
 
1. First run the container as described above.
2. Connect to the running host (`localhost` if running in your computer):
	* Using VNC: 

		Connect to specified VNCPORT (e.g. `localhost:0` or `localhost:5900`)
	
		 
	* Using SSH: 

		Connect to specified host (e.g. `localhost`) and SSHPORT (e.g. 2222) 
		
			$ ssh -p2222 debian@localhost

### Additional files

    ./etc/supervisor.conf

#### Contents:    

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
