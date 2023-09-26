# EASY LAMP install/uninstall script for ubuntu or wsl win 10
Please kindly note that this script is currently under development and may have some bugs.
Please feel free to report any bugs that may occur during the installation process. Your assistance and support are highly appreciated.


To download the script tou can use the following script
```
curl -O -L https://raw.githubusercontent.com/typerhack/lamp-install-script/main/lamp-install.sh
chmod +x lamp-install.sh

```
Then run:
```
sudo bash lamp-install.sh
```

When asked for phpmyadmin use following configs:
> Use apache2 <br>
> Configure db with dbconfig-common: No <br>
> If any error occured choose : ignore<br>

## Tested on:
1- win 10 - ubuntu wsl 2 <br>
2- ubuntu 22.04<br>
3- bodhi linux 7.0.0<br>


## Issues
1- Brute force method for changing mysql password is not working<br>

## To do:
1- Must add support for OS differentiation<br>
2- Must add database, table and agent creation in mysql<br>
3- Adding support for wordpress installation<br>


## logs:

### 0.28.0
1- Added support for installing wordpress core

### v0.27.3
1- Fixed problem with text log<br>
2- Fixed problem for databas<br>
3- Added exit option to the script<br>
4- Fixed $HOME address for the script<br>
5- Removing limits for root user to access phpmyadmin panel<br>
6- added support for creating new user - not fully completed<br>
7- Fixed the opton name for adding new user to mysql<br>
8- Added support for createing database with associated agent in mysql<br>


### v0.25:
1- Fixed input for the user<br>
2- Made lamp install automatic no need for user to add anything<br>
3- Made uninstll process automatic in some parts.<br>
4- Added OS type check for wsl and ubunto based distros.<br>
5- Added support for installing VSCode<br>
6- Fixed bug for vscode running/installation<br>
7- Fixed system reboot<br>
8- Fixed info.php test creation file<br>
9- Fixed bugs for adding necessary configs to apache2.conf<br>
10- Fixed text colors for log<br>
11- Edited query for mysql root password change <br>
12- Fixing Problem for gitweb<br>
13- Removed update and upgrade from uninstalling php<br>
14- Fixed problem with password changing query<br>
15- Added support for removing symbolic link whil uninstalling LAMP <br>

### v0.1
raw initialisation of script<br>
