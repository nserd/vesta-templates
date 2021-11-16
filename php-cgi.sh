#!/bin/bash

PHP=$1                                         # phpX.X
VERSION=`echo $PHP | sed 's#php##g'`           # X.X
VERSION_NAME=`echo $VERSION | tr -d '\.'`      # XX

function usage {
    echo "Creates PHP-CGI template for VestaCP"
    echo "Usage: $0 phpX.X"
}

function check-input {
    if [ -z $PHP ] || [ $1 == "-h" ] || [ $1 == "--help" ]
    then
        usage
        exit 0
    fi
  
    if [ `echo $PHP | grep -cE "^php"` -eq 0 ] || [ `echo -n $VERSION | wc -c` -eq 0 ] 
    then
        echo "Incorrect input."
        echo "Help: $0 --help"
        exit -1
    fi
}

function request-continue {
    read -p "The installation was completed with errors. Continue? [y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
}

function edit-template {
    CGI_STRING="wrapper_script=\x27#!/usr/bin/$PHP_CGI -cphp-cgi.ini\x27"
    sed -i "/wrapper_script=/d" $1
    sed -i "/docroot/ a\\$CGI_STRING" $1
}

function create-template {
    cp -v $TEMPLATES_PATH/phpcgi.sh $TEMPLATES_PATH/phpcgi$VERSION_NAME.sh
    cp -v $TEMPLATES_PATH/phpcgi.tpl $TEMPLATES_PATH/phpcgi$VERSION_NAME.tpl
    cp -v $TEMPLATES_PATH/phpcgi.stpl $TEMPLATES_PATH/phpcgi$VERSION_NAME.stpl

    edit-template $TEMPLATES_PATH/phpcgi$VERSION_NAME.sh
}

function install-ubuntu {
    add-apt-repository ppa:ondrej/php -y

    if [ $? -ne 0 ]
    then
    echo -e "\e[31mFailed to add repository.\e[0m"
        echo "Perhaps the locale is different from UTF-8"
        exit -1
    fi

    apt install -y $PHP $PHP-cgi $PHP-apcu $PHP-mbstring $PHP-bcmath $PHP-cli $PHP-curl $PHP-gd $PHP-intl $PHP-mcrypt $PHP-mysql $PHP-soap $PHP-xml $PHP-zip $PHP-memcache $PHP-memcached $PHP-zip
	
    if [ $? -ne 0 ]
    then
        request-continue
    fi

    create-template
    a2enmod actions cgi
}

function install-centos {
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum install -y yum-utils

    yum-config-manager --enable remi-php$VERSION_NAME

    yum install -y php$VERSION_NAME-php php$VERSION_NAME-php-cgi php$VERSION_NAME-php-apcu php$VERSION_NAME-php-mbstring php$VERSION_NAME-php-bcmath php$VERSION_NAME-php-cli php$VERSION_NAME-php-curl php$VERSION_NAME-php-gd php$VERSION_NAME-php-intl php$VERSION_NAME-php-mcrypt php$VERSION_NAME-php-mysql php$VERSION_NAME-php-soap php$VERSION_NAME-php-xml php$VERSION_NAME-php-zip php$VERSION_NAME-php-memcache php$VERSION_NAME-php-memcached php$VERSION_NAME-php-zip 
         
    if [ $? -ne 0 ]
    then
        request-continue
    fi

    create-template
}

function install-debian {
    apt -y install lsb-release apt-transport-https ca-certificates 
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
    apt update

    apt install -y $PHP $PHP-cgi $PHP-apcu $PHP-mbstring $PHP-bcmath $PHP-cli $PHP-curl $PHP-gd $PHP-intl $PHP-mcrypt $PHP-mysql $PHP-soap $PHP-xml $PHP-zip $PHP-memcache $PHP-memcached $PHP-zip
	
    if [ $? -ne 0 ]
    then
        request-continue
    fi

    create-template
    a2enmod actions cgi
}

check-input $1

if [ `cat /etc/*-release | grep -ic centos` -ne 0 ]
then
    PHP_CGI="php$VERSION_NAME-cgi"
    TEMPLATES_PATH="/usr/local/vesta/data/templates/web/httpd"

    install-centos
elif [ `cat /etc/*-release | grep -ic ubuntu` -ne 0 ] 
then
    PHP_CGI="php-cgi$VERSION"
    TEMPLATES_PATH="/usr/local/vesta/data/templates/web/apache2"

    install-ubuntu
elif [ `cat /etc/*-release | grep -ic debian` -ne 0 ] 
then
    PHP_CGI="php-cgi$VERSION"
    TEMPLATES_PATH="/usr/local/vesta/data/templates/web/apache2"

    install-debian
else
    echo "Distribution is not supported. Exit."
fi
