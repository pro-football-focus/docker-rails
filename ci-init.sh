#!/bin/bash
set -e

# Authenticate using temporary IAM Role credentials
curl --silent http://169.254.170.2:80$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > aws_credentials.json
AWS_ACCESS_KEY_ID=`jq -r '.AccessKeyId' aws_credentials.json `
AWS_SECRET_ACCESS_KEY=`jq -r '.SecretAccessKey' aws_credentials.json`
AWS_SESSION_TOKEN=`jq -r '.Token' aws_credentials.json`
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set aws_session_token $AWS_SESSION_TOKEN
aws configure set region $AWS_REGION

# Pull SSH key from S3
aws s3 cp s3://pff-ci-keys/pfftest ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
ssh-keyscan -H github.com >> $HOME/.ssh/known_hosts

# Start postgres
gosu postgres pg_ctl -D "$PG_DATA" -o "-c listen_addresses='*'"  -w start

redis-server --daemonize yes

rabbitmq-server -detached

exec "$@"
