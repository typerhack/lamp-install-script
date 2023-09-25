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
2- ubuntu 22.04
3- bodhi linux 7.0.0


## To do:
1- Must add support for OS differentiation
2- Must add database, table and agent creation in mysql


## logs:
### v0.2:
1- Fixed input for the user
2- Made lamp install automatic no need for user to add anything
3- Made uninstll process automatic in some parts.
4- Added OS type check for wsl and ubunto based distros.
5- Added support for installing VSCode
6- Fixed bug for vscode running/installation
7- Fixed system reboot

### v0.1
raw initialisation of script
