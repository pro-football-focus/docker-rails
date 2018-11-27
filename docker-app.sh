#!/bin/sh

# Check if we need to load secrets from S3 into the environment
if [[ -n "$SECRETS_FILE" ]]; then
  echo "---- Loading S3 secrets into environment from ${SECRETS_FILE} ----"
  eval $(aws s3 cp s3://${SECRETS_FILE} - --region ${AWS_DEFAULT_REGION} | sed 's/^/export /')
else
  echo "---- No secrets file specified, ignoring ----"
fi

# Setup and start the rails application
cd /app; ./bin/foreman s
