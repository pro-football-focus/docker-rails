FROM alpine:3.8
MAINTAINER Geoff Lane <geoff.lane@profootballfocus.com>

ENV RAILS_ENV "production"
ENV RACK_ENV "production"

# Install ruby and dependencies
RUN apk --update --upgrade --no-cache add \
    curl-dev ruby-dev build-base alpine-sdk coreutils postgresql-dev mysql-dev \
    zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev libffi-dev \
    ruby ruby-io-console ruby-json ruby-bigdecimal git yaml nodejs npm && \
    find / -type f -iname \*.apk-new -delete

# Install bundler and configure it
RUN gem install -N bundler && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    cp ~/.gemrc /etc/gemrc && \
    chmod uog+r /etc/gemrc && \
    bundle config --global build.nokogiri  "--use-system-libraries"

RUN apk --update --upgrade --no-cache -v add groff less python python-dev py-pip && \
    pip install awscli && \
    apk --purge -v del py-pip

# Add our app server daemon
RUN mkdir -p /etc/service/app
ADD docker-app.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run
ENTRYPOINT /etc/service/app/run

# Make sure we start up in the app directory
WORKDIR /app
