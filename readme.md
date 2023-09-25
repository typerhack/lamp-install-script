# EASY LAMP install/uninstall script for ubuntu or wsl win 10
Please kindly note that this script is currently under development and it  is not ready to use yet.
This is currently tested on win 10 wsl ubuntu.


To download the script tou can use the following script
```
curl -O -L https://raw.githubusercontent.com/typerhack/lamp-install-script/main/lamp-install.sh
chmod +x lamp-install.sh

```
Then run:
```
sudo bash lamp-install.sh
```

## Tested on:
1- win 10 - ubuntu wsl 2 <br>
2- ubuntu 22.04<br>
3- bodhi linux 7.0.0<br>


## Issues
1- Currently the root pass configuration not working as it should<br>
2- Also brute force method for changing mysql password is not working<br>

## To do:
1- Must add support for OS differentiation<br>
2- Must add database, table and agent creation in mysql<br>
3- Adding support for wordpress installation


## logs:

### v0.26
1- Fixed problem with text log<br>
2- Fixed problem for databas<br>
3- Added exit option to the script<br>
4- Added support for phpmyadmin user<br>

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
