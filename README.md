# Builds a customized Mailserver Docker Image based on Modoboa

## Table of contents
* [About](#about)
* [Installation](#installation)
* [Running the Mailserver](#running-the-mailserver)
* [Accessing Modoboa's Webinterface](#webinterface)
* [Enabling DKIM-signed Emails](#dkim)
* [Using CalDAV and CardDAV for synchronized calendars and contacts](#using-caldav-and-carddav)
* [DNS Settings](#dns-settings)
* [Replacing SSL-Certificates and -Keys](#replacing-ssl-certs)
* [Technical background](#technical-background)
* [Avoiding the necessity of sudo](#avoiding-the-necessity-of-sudo)
* [Supported CPU Architectures](#supported-cpu-architectures)
* [Links](#links)

## <a name="about"></a>About

The **mklive.sh** script builds a customized **mdb-live** Docker Image.

The **mdb-live** Docker Image provides a fully featured dockerized Mailserver including

- Modoboa Webinterface for  
	- domain and user management
	- webmailer
	- managing calenders and contacts
	- managing autoresponse emails
- SpamAssassin Anti-Spam-Filter
- Postfix SMTP Server
- Dovecot IMAP Server
- ClamAV Virus Scanner
- AutoMX for automated mail account configuration in email clients
- Radicale CalDAV and CardDAV Server
- MariaDB Database Server
- OpenDKIM for automaticly signing outgoing emails to reduce risk of emails being falsely classified as spam
- Apache Webserver for handling requests to the Modoboa Webinterface, AutoMX and Radicale within the Docker Container running **mdb-live**
- Nginx Reverse Proxy for forwarding requests from the outside world to the Apache Webserver

(for more details see [Technical background](#technical-background))

## <a name="installation"></a>Installation
1. Clone this repository to your harddrive, e.g. by running  
``$ git clone https://github.com/tsitle/dockercontainer-mdb_dc_mklive.git``  
2. Change the working directory, e.g. by running  
``$ cd dockercontainer-mdb_dc_mklive``  
3. Copy the file _config-SAMPLE.sh_ to _config.sh_  
4. Edit _config.sh_ if you want to change the defaults  
5. run  
``$ sudo ./mklive.sh``  

At this point the Docker Image **mdb-live** should have been installed.  
You could remove the Docker Image **mdb-install** now if you wanted to.  

Now you'll need to set the Docker Container environment up:  

1. Create a directory for the dockerized Mailserver, e.g. _./dockercontainer-mailserver/_  
2. Copy the files  
_build-output/dockercontainer/docker-compose.yaml_ and  
_build-output/dockercontainer/mariadb-dbs-vanilla.tgz_ and  
_build-output/dockercontainer/dc-mdb.sh_  
from the **mdb-dc-mklive** directory to  
_./dockercontainer-mailserver/_  

## <a name="running-the-mailserver"></a>Running the Mailserver
If you experience problems with **docker-compose** you might need a more recent version of **docker-compose**.  
E.g. if you see an error message that begins with "free(): invalid pointer" when using **docker-compose** you definitely need a newer version.  
See GitHub Repositories for [docker-compose](#links) below.

### Using the Bash script dc-mdb.sh
Change the working directory, e.g. by running  
``$ cd ./dockercontainer-mailserver``  

To create and start the Mail- and Database-Server's Docker Containers run  
``$ sudo ./dc-mdb.sh up``  
Please note that it will take about 30s until all services inside the mdb-live container are running.  
When started for the first time ClamAV will update its virus signatures which can take a couple of minutes.  

Until all services are running you'll see "502 Bad Gateway" when accessing Modoboa's Webinterface.

You can verify whether all services have been started by running  
``$ sudo ./dc-mdb.sh logs -f modo``  
and wait until you see the line  
```All services have been started```  
Then hit CTRL-C to detach from the logs.

To stop the Mail- and Database-Server run  
``$ sudo ./dc-mdb.sh stop``  

To start the Mail- and Database-Server again run  
``$ sudo ./dc-mdb.sh start``  

To remove the Mail- and Database-Server's Docker Containers again run  
``$ sudo ./dc-mdb.sh down``  

For troubleshooting you can access the console output from the Docker Container's startup script by running:  
``$ sudo ./dc-mdb.sh logs``  

### Using docker-compose directly
Change the working directory, e.g. by running  
``$ cd ./dockercontainer-mailserver``  

Extract the raw DB files  
``$ tar xf mariadb-dbs-vanilla.tgz``  

To create and start the Mail- and Database-Server's Docker Containers run  
``$ sudo docker-compose -p mdb up --no-start && docker-compose -p mdb start``  

To stop the Mail- and Database-Server run  
``$ sudo docker-compose -p mdb stop``  

To start the Mail- and Database-Server again run  
``$ sudo docker-compose -p mdb start``  

To remove the Mail- and Database-Server's Docker Containers again run  
``$ sudo docker-compose -p mdb down``  

For troubleshooting you can access the console output from the Docker Container's startup script by running:  
``$ sudo docker-compose -p mdb logs modo``  

It is highly recommended to remove the file _mariadb-dbs-vanilla.tgz_ after you have verified that everything is working.  
Accidently unpacking the archive after you have set your mailserver up would overwrite the databases and therefor delete your domains, users, etc.

## <a name="webinterface"></a>Accessing Modoboa's Webinterface
If you're using the Docker Image **mdb-nginx** then you should be able
to log into Modoboa's Webinterface by opening  

```
https://<MAILHOSTNAME>.<MAILDOMAIN>  
(e.g. https://mail.localdomain.local)
```
in your browser.

Default login for Modoboa's Webinterface:  

```
  User: admin  
  Password: password  
```

## <a name="dkim"></a>Enabling DKIM-signed Emails
When creating a new domain you may enable DKIM-signed emails by activating the option **Enable DKIM signing** in the create domain entry dialog in Modoboa's webinterface.  
You may also enable that option for existing domains.  

A key length of 2048 is advisable since 1024 is considered weak and 4096 may not be supported by all email servers.

Also see the section [DNS Settings](#dns-settings)

## <a name="using-caldav-and-carddav"></a>Using CalDAV and CardDAV for synchronized calendars and contacts
### CalDAV
1. Log into [Modoboa's Webinterface](#webinterface) as a
regular user (i.e. not the admin user)
2. go to the calendar page
3. click on "+ New calendar" on the left side of the page
4. enter a name for the calendar and
5. click on the "Create" button

You should now have created a new calendar.

To access the calendar from another application, like Mozilla Thunderbird, you'll need the calendar's URL.  
To obtain the URL click on your calendar's entry on the left side of the page and then on "Information" in the context menu.

Note that the CalDAV server (= Radicale) does not seem to be compatible with all versions of Apple's Calendar app.

### CardDAV
1. Log into [Modoboa's Webinterface](#webinterface) as a
regular user (i.e. not the admin user)
2. click on your username in the upper right corner of the page  
and click on "Settings" in the context menu
3. click on "Settings" on the left side of the page
4. click on the "Contacts" tab
5. set "Synchonize address book using CardDAV?" to "yes"
6. save the settings

To access your contacts from another application, like Mozilla Thunderbird, you'll need the URL.  
To obtain the URL, go to the contacts page and click on the "i" (Information) button on the right side of the page next to the "+ Add" button.


## <a name="dns-settings"></a>DNS Settings
### MX Record
You'll need to add a MX Record like the following to your webhoster's DNS settings:  

```
<HOSTNAME> IN A   <PUBLIC IP ADDRESS>  
     IN MX  <HOSTNAME>.<DOMAIN>.  
```  
where  
\<HOSTNAME\> might be **mail**  
\<DOMAIN\> might be **somedomain.org**  
\<PUBLIC IP ADDRESS\> might be **111.222.33.44**  

### TXT Record for DKIM
For using DKIM-signed emails you'll need to add a TXT Record to your webhoster's DNS settings:  

1. Log in as admin in Modoboa's webinterface  
2. Go to the **Domains** page  
3. Click on your domain's entry  
4. In the tab **DNS** click on **Show key** next to **DKIM key**  
5. Use the text in the second box (**Bind/named format**) for adding the TXT Record.  
Depending on your webhoster you might need to strip the text from all quotemarks, line-breaks and tabulator-chars.

## <a name="replacing-ssl-certs"></a>Replacing SSL-Certificates and -Keys
Before replacing SSL-Certificates and -Keys in the Docker Container's mountpoints  
_mountpoints-modo/ssl-certs/_ and _mountpoints-modo/ssl-keys/_,  
you should  

1. stop the Docker Containers (e.g. by using ``$ ./dc-mdb.sh stop``),  
2. replace the files and then  
3. start the Docker Containers again (e.g. by using ``$ ./dc-mdb.sh start``)  

## <a name="technical-background"></a>Technical background
**mklive.sh** uses Docker-in-Docker to generate the output Docker Image and other files.  
Therefor it needs access to the socket _/var/run/docker.sock_, which the **mklive.sh** script bind-mounts upon execution.

What **mklive.sh** does:  

* generate DB root password  
* create DB schemes for Modoboa/Amavis/Spamassassin  
create DB users + passwords for Modoboa/... DB schemes  
remove DB dumps from Install-Image  
* generate default password for user accounts that Modoboa automaticly creates  
* generate secret key for Modoboa's crypto module  
* generate docker-compose.yaml  
* create tarball of DB Server's mointpoint with raw DB files  
* create Docker Image **mdb-live** based on **mdb-install**  
* create tarball of Docker Image **mdb-live** - suitable for importing the image with Docker  

## <a name="avoiding-the-necessity-of-sudo"></a>Avoiding the necessity of sudo
To run Docker commands without having to use sudo all the time,  
you'll need to add your user to the 'docker' usergroup:

```
$ sudo usermod -a -G docker <USERNAME>
```
Then log out from your current shell (or close the terminal window)  
and log in again (or open a new terminal window).

Be aware of possible security implications though.  
See [Docker daemon attack surface link](#docker-daemon-attack-surface) below for more information.

## <a name="supported-cpu-architectures"></a>Supported CPU Architectures
* amd64/x86_64
* aarch64/arm64v8/arm64
* armv7l/arm32v7/armhf

## <a name="links"></a>Links
### Modoboa documentation
- [Modoboa documentation](https://modoboa.readthedocs.io/)

### GitHub Repositories
- Docker Image [mdb-mkinstall](https://github.com/tsitle/dockerimage-mdb_mkinstall)
- Docker Container [mdb-dc-mkinstall](https://github.com/tsitle/dockercontainer-mdb_dc_mkinstall)
- Docker Image [mdb-mklive](https://github.com/tsitle/dockerimage-mdb_mklive)
- Docker Container [mdb-dc-mklive](https://github.com/tsitle/dockercontainer-mdb_dc_mklive)
- **docker-compose** binary for  
[amd64/x86_64](https://github.com/tsitle/dockercompose-binary_and_dockerimage-amd64)  
[aarch64/arm64v8/arm64](https://github.com/tsitle/dockercompose-binary\_and\_dockerimage-aarch64)  
[armv7l/arm32v7/armhf](https://github.com/tsitle/dockercompose-binary_and_dockerimage-armv7l)

### Docker Hub
- Docker Hub Repositories [tsle/](https://hub.docker.com/r/tsle/)

### <a name="docker-daemon-attack-surface"></a>Docker daemon attack surface
- [https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface)

