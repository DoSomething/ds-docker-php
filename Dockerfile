FROM ubuntu:14.04
MAINTAINER Morgan Rich

ENV DEBIAN_FRONTEND noninteractive

RUN sudo apt-get update
RUN sudo apt-get -y install curl ruby software-properties-common build-essential
RUN sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN sudo apt-get update

RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
RUN sudo apt-get install -y nodejs

RUN npm install bower gulp gulp-imagemin
RUN gem install bundler

RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.0 mongodb-org php7.0-mongo php7.0-common php7.0-gd php7.0-mysql php7.0-curl php7.0-json php7.0-readline php7.0-cli php7.0-mbstring php7.0-mcrypt php7.0-mongodb php7.0-mysql php7.0-xml php7.0-zip

RUN sudo curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer

RUN mkdir -p /etc/ssl/private/storage/keys/ && sudo openssl genrsa -out /etc/ssl/private/storage/keys/private.key 1024
RUN sudo openssl rsa -in /etc/ssl/private/storage/keys/private.key -pubout -out /etc/ssl/private/storage/keys/public.key

# Copy the database schema to the /data directory
ADD files/run_db.sh files/init_db.sh ./

# Install and Initialize MySQL DB
RUN sudo -E apt-get -q -y install mysql-server
RUN chmod +x ./init_db.sh ./run_db.sh
RUN sudo su && ./init_db.sh

VOLUME /var/lib/mysql

EXPOSE 3306
ENV DEBIAN_FRONTEND teletype

ENTRYPOINT "/tmp/run_db"
