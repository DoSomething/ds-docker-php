FROM ubuntu:14.04
MAINTAINER Morgan Rich

ENV DEBIAN_FRONTEND noninteractive

RUN sudo apt-get update
RUN sudo apt-get -y install apt-transport-https wget
RUN sudo apt-get update

# Install ChromeDriver
RUN sudo apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
RUN sudo apt-get -y install chromium-browser

# Configure MongoDB 3.6 Dependencies
RUN sudo apt-get -y install curl git libnotify-bin ruby software-properties-common build-essential
RUN sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN sudo apt-get update

# Install Node 8.x LTS
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# Install Bundler
RUN gem install bundler

# Install PHP 7.2 & MongoDB 3.6
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
php7.2 mongodb-org php7.2-mongo php7.2-common php7.2-dev php7.2-fpm php7.2-cli \
php7.2-bcmath php7.2-bz2 php7.2-dba php7.2-gd php7.2-mysql php7.2-curl php7.2-json php7.2-readline php7.2-mbstring php7.2-mongodb php7.2-soap php7.2-xml php7.2-zip 

# Install New Relic extension (for platform reqs):
RUN sudo sh -c "echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list"
RUN wget -O- https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -
RUN sudo apt-get update

RUN sudo DEBIAN_FRONTEND=noninteractive apt-get -y install newrelic-php5

# Install Composer
RUN sudo curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer

# Configure MySQL
RUN { \
    echo mysql-community-server mysql-community-server/data-dir select ''; \
    echo mysql-community-server mysql-community-server/root-pass password ''; \
    echo mysql-community-server mysql-community-server/re-root-pass password ''; \
    echo mysql-community-server mysql-community-server/remove-test-db select false; \
  } | debconf-set-selections \
  && apt-get update && apt-get install -y mysql-server && sudo service mysql start && mysql -u root -e "CREATE USER 'homestead'@'localhost' IDENTIFIED BY 'secret';" \
  && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'localhost' WITH GRANT OPTION;"

EXPOSE 3306
ENV DEBIAN_FRONTEND teletype

CMD ["/usr/bin/mongod", "--config", "/etc/mongod.conf", "--fork", "--logpath", "/var/log/mongod.log"]

ENTRYPOINT "/bin/bash"
