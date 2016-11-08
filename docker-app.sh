#!/bin/bash

# Set the dockerhost host so that applications can communicate with each other
# via shared host ports on the docker host machine.
echo "`/sbin/ip route|awk '/default/ { print  $3}'` dockerhost" >> /etc/hosts

# Setup and start the rails application
cd /app; RAILS_ENV=$RAILS_ENV; bundle install && \
                               bundle exec rake db:migrate && \
                               bundle exec rake assets:precompile && \
                               bundle exec rails s -p 3000 -b '0.0.0.0' -e $RAILS_ENV