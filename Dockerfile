FROM phusion/baseimage:0.9.19
MAINTAINER Pro Football Focus <devops@profootballfocus.com>
LABEL org.label-schema.vcs-url="https://github.com/pro-football-focus/docker-rails"
ENV REFRESHED_AT 2016-11-09

# Setup the environment
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo /root > /etc/container_environment/HOME

# Use the baseimage init system
CMD ["/sbin/my_init"]

# Create the volume we'll put our code into
VOLUME /app

# Make the required ports available
EXPOSE 3000

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Prepare to install packages
WORKDIR /tmp

# Install required packages (includes Ruby 2.2.2 + Rails 4.2.4)
RUN apt-get update && \
    apt-get install --no-install-recommends -y iproute git curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev && \
    curl -O http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz && \
    tar -xzf ruby-2.2.2.tar.gz -C /tmp && \
    cd /tmp/ruby-2.2.2 && \
    ./configure && \
    make && \
    make install && \
    gem install bundler && \
    gem install rails -v 4.2.4 && \
    make clean && \
    apt-get remove --purge -y curl zlib1g-dev build-essential libssl-dev libreadline-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add our app server daemon
RUN mkdir /etc/service/app
ADD docker-app.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run

# Make sure we start up in the app directory
WORKDIR /app