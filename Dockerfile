# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# @trenpixster wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return
# ----------------------------------------------------------------------------

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
#
# Usage Example : Run One-Off commands
# where <VERSION> is one of the baseimage-docker version numbers.
# See : https://github.com/phusion/baseimage-docker#oneshot for more examples.
#
#  docker run --rm -t -i phusion/baseimage:<VERSION> /sbin/my_init -- bash -l
#
# Thanks to @hqmq_ for the heads up
FROM phusion/baseimage:0.9.19
MAINTAINER Pro Football Focus <devops@profootballfocus.com>
LABEL org.label-schema.vcs-url="https://github.com/pro-football-focus/docker-rails"

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2016-11-07

# Set time timezone
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# Set correct environment variables.

# Setting ENV HOME does not seem to work currently. HOME is unset in Docker container.
# See bug : https://github.com/phusion/baseimage-docker/issues/119
#ENV HOME /root
# Workaround:
RUN echo /root > /etc/container_environment/HOME

# Use baseimage-docker's init system.
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

# Install Ruby 2.2.2
WORKDIR /ruby
RUN apt-get update
RUN apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
RUN curl -O http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
RUN tar -xzf ruby-2.2.2.tar.gz -C /ruby
WORKDIR /ruby/ruby-2.2.2
RUN ./configure
RUN make
RUN make install
RUN gem install bundler
RUN gem install rails -v 4.2.4

# Clean up from the install process
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add our app server daemon
RUN mkdir /etc/service/app
ADD docker-app.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run

# Make sure we start up in the app directory
WORKDIR /app