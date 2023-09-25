#!/bin/bash

# Give the necessary premisions to the file using "chmod +x lamp-install.sh"
# To run the script use "sudo ./lamp-install.sh"

#------------------------------------------------------------------------------

# Script Version
script_version="0.27.1"

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
        sudo mysql -uroot -e"ALTER USER 'root'@'localhost' IDENTIFIED BY '$passvar';" 

        if [ $? -eq 0 ]
        then
        echo "${green}root user password changed. make sure to remember your password.${clear}"

        sudo mysql -uroot -p$passvar -e"FLUSH PRIVILEGES;"

        echo -e "${yellow}Removing root user limits...${clear}"
        sudo mysql -uroot -ppassword -e"UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root'; FLUSH PRIVILEGES;"

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
    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
    service_restart
    echo You can now use phpmyadmin via ${green}localhost/phpmyadmin${clear} using your ${green}root${clear} username and specified password.
    echo "Done!"
}

# Add projects shortcut to home as a symbolic link
create_project_shortcut () {
    echo -e ${cyan}Adding webdev shortcuts to home as a ${yellow}symbolic link${clear}.
    ln -s /var/www/html $HOME/webdev
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
        echo ${yellow}What is your root account password:${clear}
        read -sp "root account password:" rootuserpass

    }
    new_mysql_user_pass
    
    while [ $newusermysqlpass != $newusermysqlpassconfirm ]
    do
        echo ${yellow}Password do not match....${clear}
        new_mysql_user_pass
    done
    
    if [ $newusermysqlpass = $newusermysqlpassconfirm ]
    then
        echo -e ${yellow}creating phpmyadmin user...${clear} 
        sudo mysql -uroot -p$rootuserpass -e"CREATE USER '$newusermysql'@'localhost' IDENTIFIED BY '$newusermysqlpass';"
        sudo mysql -uroot -p$rootuserpass -e"GRANT ALL PRIVILEGES ON yourdatabase.* TO 'phpmyadminuser'@'localhost';"
        sudo mysql -uroot -p$rootuserpass -e"FLUSH PRIVILEGES;"
        
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

echo -e "${yellow}This script will let you install LAMP with phpmyadmin.\nPlease choose your desired action:${clear}\n"

echo -e "${green}The script version is: $script_version${clear}"

echo -e "1- Installing LAMP with phpmyadmin\n"
echo -e "2- Uninstalling the LAMP with phpmy admin\n"
echo -e "3- Creating a database with agent in mysql\n"
echo -e "4- Changing mysql root password\n"
echo -e "5- Installing git only\n"
echo -e "6- Restart Services\n"
echo -e "7- Run VSCode\n"
echo -e "8- Reboot system\n"
echo -e "9- Installing VSCode\n"

echo -e "q- Exit\n"
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
    9)
        install_vscode
        ;;
    q)
        exit
        ;;
esac










