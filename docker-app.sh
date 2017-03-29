#!/bin/sh

# Export docker secrets with "ENV_" prefix into execution context
for i in /run/secrets/ENV_*; do
  eval $(cat ${i} | sed "s/^/export ${i#/run/secrets/ENV_}=/")
done

# Setup and start the rails application
cd /app; bundle exec rake db:migrate && foreman start
