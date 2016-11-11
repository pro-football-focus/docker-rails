#!/bin/bash

# Set the dockerhost host so that applications can communicate with each other
# via shared host ports on the docker host machine.
echo "`/sbin/ip route|awk '/default/ { print  $3}'` dockerhost" >> /etc/hosts

# Build assets if in production mode
if [ $RAILS_ENV == "production" ]
then
  cd /app; RAILS_ENV=production bundle exec rake assets:precompile
fi

# Setup and start the rails application
cd /app; RAILS_ENV=$RAILS_ENV; bundle install && \
                               bundle exec rake db:migrate && \
                               nginx