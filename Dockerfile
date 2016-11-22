FROM phusion/baseimage:0.9.19
MAINTAINER Pro Football Focus <devops@profootballfocus.com>
LABEL org.label-schema.vcs-url="https://github.com/pro-football-focus/docker-rails"
ENV REFRESHED_AT 2016-11-09

# Setup the environment
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo /root > /etc/container_environment/HOME

# Use the baseimage init system
CMD ["/sbin/my_init"]

# Make the required ports available
EXPOSE 3000

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Prepare to install packages
WORKDIR /tmp

# Install Ruby 2.3.2 + Rails 4.2.7
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev && \
    curl -O http://ftp.ruby-lang.org/pub/ruby/2.3/ruby-2.3.2.tar.gz && \
    tar -xzf ruby-2.3.2.tar.gz -C /tmp && \
    cd /tmp/ruby-2.3.2 && \
    ./configure && \
    make && \
    make install && \
    gem install bundler && \
    gem install rails -v 4.2.7 && \
    make clean && \
    apt-get remove --purge --auto-remove -y zlib1g-dev build-essential libssl-dev libreadline-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Passenger + Nginx
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt-get install -y apt-transport-https ca-certificates && \
    echo "\ndeb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main" >> /etc/apt/sources.list.d/passenger.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y nginx-extras passenger && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/bin/ruby* /usr/lib/ruby/2.3.0 && \
    ln -s /usr/local/bin/ruby /usr/bin/ruby

# Install dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y git inotify-tools iproute libmysqlclient-dev libpq-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -s /usr/bin/nodejs /usr/bin/node

# Install NodeJS v6
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y nodejs && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Configure nginx
COPY ./docker-passenger.conf /etc/nginx/passenger.conf
COPY ./docker-nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Add our app server daemon
RUN mkdir /etc/service/app
ADD docker-app.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run

# Make sure we start up in the app directory
WORKDIR /app
