#!/bin/bash

# Give the necessary premisions to the file using "chmod +x lamp-install.sh"
# To run the script use "sudo ./lamp-install.sh"

#------------------------------------------------------------------------------

# Script Version
script_version="0.29.3"

#------------------------------------------------------------------------------

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

# Cheking OS
echo -e "${yellow}What is your OS:${clear}"
echo -e "${yellow}1- Windows wsl${clear}"
echo -e "${yellow}2- Ubuntu based linux${clear}"
read -p "Choose your OS type:" os_type
while [[ "$os_type" -ne 1 && "$os_type" -ne 2 ]]
do
    echo -e ${red}You have to choose your OS type.${clear}
    echo -e "${yellow}What is your OS:${clear}"
    echo -e "${yellow}1- Windows wsl${clear}"
    echo -e "${yellow}2- Ubuntu based linux${clear}"
    read -p "Choose your OS type:" os_type
done
case $os_type in
    1)
        echo You have chosen wsl.
        echo -e ${yellow}It is recommended to use wsl 2. For more information check the following website: https://learn.microsoft.com/en-us/windows/wsl/install${clear}
        ;;
    2)
        echo you have choosen Ubuntu.
        ;;
esac


#------------------------------------------------------------------------------
# This Part contains deifferent fuctions used in the scripts

# System Update
sys_update () {
    echo -e ${cyan}"Upgrading system..."${clear}
    sudo apt update && sudo apt upgrade -y
    echo -e ${green}System updated.${clear}
}

lamp_install () {
    echo -e ${yellow}Installing LAMP now...${clear}
    sudo apt install lamp-server^ -y

    # Editing apache2.conf
    echo -e ${yellow}Adding necessary lines to apache2.conf.${clear}
    echo -e "Servername localhost\nAcceptFilter http none\nAcceptFilter https none" >> /etc/apache2/apache2.conf
    echo -e ${green}LAMP installed.${clear}
}

# This function restarts the necessary services
service_restart () {
    echo -e ${cyan}Restarting services...${clear}
    echo -e ${yellow}Restarting apache2...${clear}
    sudo systemctl restart apache2
    echo -e ${green}apache2 restarted.${clear}
    echo -e ${yellow}Restarting mysql.service...${clear}
    sudo systemctl restart mysql.service
    echo -e ${green}mysql.service restarted.${clear}
    echo "Done!"
}

# This function creates a test file
create_test_file () {
    echo -e ${cyan}Creating test file...${clear}
    touch /var/www/html/info.php
    echo -e "<?php\nphpinfo();\n?>" > /var/www/html/info.php
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
        echo -e ${yellow}changing mysql root account password...${clear}
        echo -e "${yellow}Removing root user limits...${clear}"
        sudo mysql -uroot -e"ALTER USER 'root'@'localhost' IDENTIFIED BY '$passvar';UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';FLUSH PRIVILEGES;" 
        echo "Done!"

        service_restart
    fi
}

# This function changes the password for root username for the first time
change_root_pass () {
    echo -e "${yellow}You must change mysql root account password."${clear}

    checkPassword
    while [ $passvar != $passvarconfirm ]
    do
        echo -e ${red}Passwords did not match...${clear}
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
    echo -e "${cyan}Installing phpmyadmin...${clear}"
    sudo apt-get install -y phpmyadmin

    # Adding phpmyadmin to apache2
    echo "# This lines adds phpmyadmin to apache2" >> /etc/apache2/apache2.conf
    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
    service_restart
    echo You can now use phpmyadmin via ${green}localhost/phpmyadmin${clear} using your ${green}root${clear} username and specified password.
    echo "Done!"
}

# Add projects shortcut to home as a symbolic link
create_project_shortcut () {
    echo -e ${cyan}Adding webdev shortcuts to home as a symbolic link${clear}.
    echo -e "${yellow}It the shorcut did not created, please use the following command for adding shortcut for your projects to your $HOME: \"sudo ln -s /var/www/html $HOME/webdev\""
    sudo ln -s /var/www/html $HOME/webdev
    echo -e "${green}You can now access your file via webdev folder.${clear}"
    echo -e "Done!"
}

# This function adds necessary user premissions to current user
add_user_premission () {
    echo -e ${yellow}Adding necessary permissions to user...${clear}
    sudo chown -R $USER /var/www/html/
    echo "Done!"
}

# This Function installs git
git_install () {
    echo -e ${yellow}Installing git${clear}
    sudo apt install git-all -y
    echo "Done!"
}

# This function runs vscode
run_vscode () {
    echo -e "${yellow}Running VSCode server...${clear}"
    cd webdev
    code .
}

# This function installs vscode
install_vscode () {
    echo -e ${yellow}Installing VSCode....${clear}

    sudo apt install wget gpg -y
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https -y
    sudo apt update
    sudo apt install code -y
    echo -e "${green}You can now use vscode type'code' in terminal to open the program.${clear}"
    echo "Done!"
}


# This function create a database with associated agent in mysql
create_database_agent_mysql () {

    echo -e ${yellow}Please enter a new username for mysql:${clear}
    read -p "New username:" newusermysql

    new_mysql_user_pass () {
        echo -e ${yellow}Please specify a password for your root account:${clear}
        read -sp "New user password:" newusermysqlpass
        echo
        read -sp "confirm password:" newusermysqlpassconfirm
        echo
        

    }
    new_mysql_user_pass
    
    while [ $newusermysqlpass != $newusermysqlpassconfirm ]
    do
        echo -e ${yellow}Password do not match....${clear}
        new_mysql_user_pass
    done
    
    if [ $newusermysqlpass = $newusermysqlpassconfirm ]
    then
        echo ${yellow}What is your root account password:${clear}
        read -sp "root account password:" rootuserpass
        echo -e ${yellow}creating phpmyadmin user...${clear} 
        sudo mysql -uroot -p$rootuserpass -e"CREATE USER '$newusermysql'@'localhost' IDENTIFIED BY '$newusermysqlpass';GRANT ALL PRIVILEGES ON yourdatabase.* TO 'phpmyadminuser'@'localhost';FLUSH PRIVILEGES;"
        
        service_restart
    fi


    
}

# This function creates a database with agent
create_database_with_agent () {
    ech0 -e "${yellow}Initialising... Please provide us with some data:${clear}"

    read -p "What is your database name?" new_database_name
    read -p "What is the username to associate with database?" new_database_user

    new_database_user_pass () {
        echo -e ${yellow}Please enter a password  for \"$new_database_user\":${clear}
        read -sp "New user password:" newdatabaseuserpass
        echo
        read -sp "confirm password:" newdatabaseuserpassconfirm
        echo
        
        while [ $newdatabaseuserpass != $newdatabaseuserpassconfirm ]
        do
            echo -e ${yellow}Passwords do not match....${clear}
            new_database_user_pass
        done

    }
    new_database_user_pass

    if [ $newusermysqlpass = $newusermysqlpassconfirm ]
    then
        echo -e ${yellow}What is your root account password:${clear}
        read -sp "root account password:" newuserrootuserpass

        echo -e "${yellow}Creating database...${clear}"
        echo -e "${yellow}Creating agent...${clear}"
        echo -e "${yellow}Associating database with agent...${clear}"

        sudo mysql -uroot -p$newuserrootuserpass -e"CREATE DATABASE $new_database_name;USE $new_database_name;CREATE USER '$new_database_user'@'localhost' IDENTIFIED BY '$newdatabaseuserpass';GRANT ALL PRIVILEGES ON $new_database_name.* TO '$new_database_user'@'localhost';FLUSH PRIVILEGES;"

        echo "Done!"
        
        service_restart
    fi

    
}


# This function install LAMP, phpmyadmin and git
lamp_php_install () {
    
    # 1- Upgrading system
    sys_update

    # 2- Installing LAMP 
    sudo apt purge gitweb -y   
    lamp_install

    # 3- Restarting installed services
    service_restart
    sudo apt install gitweb -y
    
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
    

    echo -e "${green}LAMP successfully installed!${clear}"

    # 10- Running vs code server
    case $os_type in
    1)
        read -p "Do you want to run VS code?[y/n]"  vscode_answer
        while [[ $vscode_answer != y && $vscode_answer != Y && $vscode_answer != n && $vscode_answer != N ]]
        do
            
            echo -e ${red}You must choose y/n only.${clear}
            read -p "Do you want to run VS code?[y/n]"  vscode_answer
        done


        case $vscode_answer in
        y|Y)
            echo "Running VS Code server..."
            run_vscode
            ;;
        n|N)
            echo "Done. Enjoy developing for web."
            ;;
        esac
        
        
        ;;
    2)
        read -p "Do you want to install VS code?[y/n]"  vscode_install
        while [[ $vscode_install != y && $vscode_install != Y && $vscode_install != n && $vscode_install != N ]]
        do
            echo -e ${red}You must choose y/n only.${clear}
            read -p "Do you want to install VS code?[y/n]"  vscode_install
        done

        case $vscode_install in
        y|Y)
            echo "Installing VS Code..."
            install_vscode
            ;;
        n|N)
            echo -e "${green}Done. Enjoy developing for web.${clear}"
            ;;
        esac        
        ;;
    esac

    

}

# This function installs wordpress core
install_wordpress () {
    echo -e "What is your wordpress project name? (no spaces)"
    read -p "Wordpress project name: " wpname
    sudo mkdir /var/www/html/$wpname
    sudo wget -P /var/www/html/$wpname https://wordpress.org/latest.tar.gz
    sudo tar -xzvf /var/www/html/$wpname/latest.tar.gz -C /var/www/html/$wpname --strip-components=1
    sudo rm /var/www/html/$wpname/latest.tar.gz

    echo -e "${yellow}Adding necessary permissions...${clear}"
    cd /var/www/html/$wpname
    sudo chown -R www-data:www-data /var/www/html/$wpname
    sudo chmod -R 755 /var/www/html/$wpname

    echo -e "${yellow}Adding necessary configs to apache2...${clear}"
    sudo systemctl stop apache2
    echo -e "<Directory /var/www/html/$wpname>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" >> /etc/apache2/apache2.conf
    sudo systemctl start apache2
    service_restart
    echo -e "${green}Wordpress Installed.${clear}"
    cd $HOME

    echo -e "${yellow}Adding necessary permissions to user for adding/editing files and folders...${clear}"
    current_username=$(whoami)
    echo "The current username is: $current_username"
    sudo chown -R $current_username:$current_username /var/www/html/$wpname
    sudo chmod -R 755 /var/www/html/$wpname


    echo "Done!"

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
    sudo reboot now   
}

uninstall_vscode () {
    echo ${yellow}Uninstalling VSCode...${clear}
    sudo apt remove code -y
    echo "Done!"
}


# This function uninstalls LAMP, phpmyadmin and git
lamp_php_uninstall () {
    echo -e "${yellow}Uninstalling LAMP may take a while. Please wait patiently. Do not quite the process otherwise you might break your system.${clear}"
    uninstall_apache2
    uninstall_php
    uninstall_mysql

    #removing project shortcut
    rm ~/webdev

    echo -e "${yellow}It is recommended to reboot your system. Do you want to reboot your system now?[y|n]${clear}"
    read -p "Reboot now?[y|n]" rebootvar
    while [[ $rebootvar != 'y' && $rebootvar != 'Y' && $rebootvar != 'n' && $rebootvar != 'N' ]]
    do
        echo -e "${red}You must choose y/n only.${clear}"
        echo -e "${yellow}It is recommended to reboot your system. Do you want to reboot your system now?[y|n]${clear}"
        read -p "Reboot now?[y|n]" rebootvar
    done

    case $rebootvar in
    y|Y)
        echo "Rebooting system..."
        system_reboot 
        ;;
    n|N)
        echo -e "${yellow} It is recommended to reboot your system. Please manually reboot your system later.${clear}"
        echo -e "${green} Uninstalling done~${clear}"
        clear
        exit
    esac

}
#------------------------------------------------------------------------------

echo -e "${green}The script version is: $script_version${clear}\n"
echo -e "${yellow}This script will let you install LAMP with phpmyadmin.\nPlease choose your desired action:${clear}\n"

echo 1- Installing LAMP with phpmyadmin
echo 2- Uninstalling the LAMP with phpmy admin
echo 3- Add new user to mysql
echo 4- Changing mysql root password
echo 5- Create database with agent in mysql
echo 6- Install git only
echo 7- Restart Services
echo 8- Run VSCo de
echo 9- Reboot system
echo 10- Install VSCode
echo 11- Install wordpress core

echo q- Exit
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
        create_database_with_agent
        ;;
    6)
        git_install
        ;;
    7)
        service_restart
        ;;
    8)
        run_vscode
        ;;
    9)
        system_reboot
        ;;
    10)
        install_vscode
        ;;
    11)
        install_wordpress
        ;;
    q)
        exit
        ;;
esac