#!/bin/bash

# Give the necessary premisions to the file using "chmod +x lamp-install.sh"
# To run the script use "sudo ./lamp-install.sh"

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'


#------------------------------------------------------------------------------
# This Part contains deifferent fuctions used in the scripts

# System Update
sys_update () {
    echo "Upgrading system..."
    sudo apt update && sudo apt upgrade -y
    echo ${green}System updated.${clear}
}

lamp_install () {
    echo "installing LAMP now..."
    sudo apt install lamp-server^ -y

    # Editing apache2.conf
    echo Adding necessary lines to apache2.conf.
    echo -e "Servername localhost\nAcceptFilter http none\nAcceptFilter https none" >> /etc/apache2/apache2.conf

    echo ${green}LAMP installed.${clear}
}

# This function restarts the necessary services
service_restart () {
    echo Restarting services...
    echo ${yellow}Restarting apache2...${clear}
    sudo systemctl restart apache2
    echo ${green}apache2 restarted.${clear}
    echo ${yellow}Restarting mysql.service...${clear}
    sudo systemctl restart mysql.service
    echo ${green}mysql.service restarted.${clear}
    echo "Done!"
}

# This function creates a test file
create_test_file () {
echo Creating test file...
    php_info_file="<?php\nphpinfo();\n?>"
    touch /var/www/html/info.php
    echo $php_info_file >> /var/www/html/info.php
    echo -e To check your test file please visit the following address: ${green}localhost/info.php${clear}
    echo "Done!"
}

# This function checks password validity
checkPassword () {
    echo
    echo -e ${yellow}Please specify a password for your root account:${clear}
    read -sp "mysql password:" passvar
    echo
    read -sp "confirm password:" passvarconfirm
    echo
    if [ $passvar = $passvarconfirm ]
    then
        echo
        echo -e ${green}Passwords matched.${clear}
        echo changing mysql root account password...
        echo
        mysql -uroot -ppassword -e"ALTER USER 'username'@'localhost' IDENTIFIED BY $passvar;"
    fi
}

# This function changes the password for root username for the first time
change_root_pass () {
    echo -e "you must change mysql root account password."

    

    checkPassword
    while [ $passvar != $passvarconfirm ]
    do
        echo -e ${red}Passwords did not match...${clear}
        echo
        echo
        checkPassword
    done
}


# This function changes the root username password using brute force method
change_root_pass_brute () {

    echo
    echo -e ${yellow}Please specify a password for your root account:${clear}
    read -sp "mysql password:" newpassvar
    echo
    read -sp "confirm password:" newpassvarconfirm
    echo
    confirm_new_pass () {
        if [ $newpassvar = $newpassvarconfirm ]
        then
            echo ${yellow}Stopping mysql.service...${clear}
            sudo systemctl stop mysql
            echo ${yellow}Bypassing password...${clear}
            sudo mysqld_safe --skip-grant-tables &
            echo ${yellow}Starting mysql.service...${clear}
            sudo systemctl start mysql
            echo ${yellow}Changing root user password${clear}
            mysql -u root -e "USE mysql;UPDATE user SET authentication_string = PASSWORD('$newpassvar') WHERE User = 'root';FLUSH PRIVILEGES;"
            echo ${yellow}Restarting mysql.service...${clear}
            sudo systemctl restart mysql
            echo ${green} Root password changed.${clear}
            echo "Done!"
        fi
    }
    while [ $newpassvar != $newpassvarconfirm ]
    do
        echo -e ${red}Passwords did not match...${clear}
        echo
        echo
        confirm_new_pass
    done

}

# This function installs phpmyadmin and changes necessary configs
phpmyadmin_install () {
    echo -e "Installing phpmyadmin..."
    sudo apt-get install -y phpmyadmin

    # Adding phpmyadmin to apache2
    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
    service_restart
    echo You can now use phpmyadmin via ${green}localhost/phpmyadmin${clear} using your ${green}root${clear} username and specified password.
    echo "Done!"
}

# Add projects shortcut to home as a symbolic link
create_project_shortcut () {
    echo Adding webdev shortcuts to home as a ${yellow}symbolic link${clear}.
    ln -s /var/www/html ~/webdev
    echo "${green}You can now access your file via webdev folder.${clear}"
    echo "Done!"
}

# This function adds necessary user premissions to current user
add_user_premission () {
    echo Adding necessary permissions to user...
    sudo chown -R $USER /var/www/html/
    echo "Done!"
}

# This Function installs git
git_install () {
    echo Installing git
    sudo apt install git-all
    echo "Done!"
}

# This function runs vscode
run_vscode () {
    echo "Running VSCode server..."
    cd webdev
    code .
}



# This function create a database with associated agent in mysql
create_database_agent_mysql () {
    echo "This feature is not implemented yet. please choose other options."
    exit
}



# This function install LAMP, phpmyadmin and git
lamp_php_install () {
    # 1- Upgrading system
    sys_update

    # 2- Installing LAMP
    lamp_install

    # 3- Restarting installed services
    service_restart

    # 4- Creating test file
    create_test_file

    # 5- Changing mysql password
    change_root_pass

    # 6- Installing phpmyadmin
    phpmyadmin_install

    # 7- Adding Shortcut to home for new websites
    create_project_shortcut

    # 8- Adding necessary permissions to user
    add_user_premission

    # 9- Installing git
    git_install

    echo "${green}LAMP successfully installed!${clear}"

    # 10- Running vs code server
    read -p "${yellow}Do you want to run VS code?[y/n]${clear}"  vscode_answer
    while [ $vscode_answer != 'y' || $vscode_answer != 'Y' || $vscode_answer != 'n' || $vscode_answer != 'N']
    do
        case $vscode_answer in
        y|Y)
            run_vscode
            ;;
        n|N)
            exit
            ;;
        *)
        echo -e "${red}Please only enter "y\|Y" or "n\|N".${clear}"
        ;;
        esac
    done

}

# This function uninstalls git
git_uninstall (){
    echo Uninstalling git...
    sudo apt remove git-all
    echo "Done!"
}

# Uninstalling apache2
uninstall_apache2 () {
    echo "Removing apache2 and it's component..."
    sudo service apache2 stop
    sudo apt-get purge apache2 apache2-utils apache2.2-bin  -y
    sudo apt remove apache2.* -y
    sudo apt-get autoremove -y
    whereis apache2
    sudo rm -rf /etc/apache2
    echo "Done!"
}

# Uninstalling php 
uninstall_php () {
    echo "Removing PHP and it's compinent..."
    php --version
    sudo apt-get purge `dpkg -l | grep php8.0| awk '{print $2}' |tr "\n" " "` -y
    sudo apt-get purge php8.* -y
    sudo apt-get autoremove --purge -y
    whereis php
    sudo rm -rf /etc/php
    sudo apt update -y
    sudo apt upgrade -y
    php --version
    echo "Done!"
}

# Uninstalling mysql
uninstall_mysql () {
    echo "Removing mysql and it's component..."
    sudo service mysql stop
    sudo apt-get remove --purge *mysql\* -y
    sudo apt-get remove --purge mysql-server mysql-client mysql-common -y
    sudo rm -rf /etc/mysql
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    echo "Done!"
}

# This function reboots the system
system_reboot () {
    echo "Rebooting the system... "
    sudo reboot

    
}


# This function uninstalls LAMP, phpmyadmin and git
lamp_php_uninstall () {
    echo "${yellow}Uninstalling LAMP may take a while. Please wait patiently. Do not quite the process otherwise you might break your system.${clear}"
    uninstall_apache2
    uninstall_php
    uninstall_mysql

    read -p "It is recommended to reboot your system. ${yellow}Do you want to reboot your system now?[y|n]${clear}" rebootvar
    while [ $rebootvar != 'y' || $rebootvar != 'Y' || $rebootvar != 'n' || $rebootvar != 'N']
    do
        case $rebootvar in
        y|Y)
            system_reboot 
            ;;
        n|N)
            echo "Please manually reboot your system later"
            exit
            ;;
        *)
        read -p "It is recommended to reboot your system. ${yellow}Do you want to reboot your system now?[y|n]${clear}" : rebootvar
        ;;
        esac
    done
}
#------------------------------------------------------------------------------

echo -e "${yellow}This script will let you install LAMP with phpmyadmin.\nPlease choose your desired action:${clear}\n"
echo -e "1- Installing LAMP with phpmyadmin\n"
echo -e "2- Uninstalling the LAMP with phpmy admin\n"
echo -e "3- Creating a database with agent in mysql\n"
echo -e "4- Changing mysql root password\n"
echo -e "5- Installing git only\n"
echo -e "6- Restart Services\n"
echo -e "7- Run VSCode\n"
echo -e "8- Reboot system\n"
echo

read -p "Choose your option:" option

case $option in
    1)
        lamp_php_install
        ;;
    2)
        lamp_php_uninstall
        ;;
    3)
        create_database_agent_mysql
        ;;
    4)
        change_root_pass_brute
        ;;
    5)
        git_install
        ;;
    6)
        service_restart
        ;;
    7)
        run_vscode
        ;;
    8)
        system_reboot
        ;;
esac










