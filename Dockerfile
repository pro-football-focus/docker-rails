FROM alpine:3.4
MAINTAINER Jake Weaver <jake.weaver@profootballfocus.com>

ENV RAILS_ENV "production"
ENV RACK_ENV "production"

RUN apk --update --upgrade add \
    curl-dev ruby-dev build-base alpine-sdk coreutils postgresql-dev mysql-dev \
    zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev libffi-dev \
    ruby ruby-io-console ruby-bigdecimal ruby-json git yaml nodejs && \
    gem install -N bundler && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    cp ~/.gemrc /etc/gemrc && \
    chmod uog+r /etc/gemrc && \
    bundle config --global build.nokogiri  "--use-system-libraries" && \
    find / -type f -iname \*.apk-new -delete && \
    rm -rf /var/cache/apk/*

RUN apk -Uuv add groff less python python-dev py-pip && \
    pip install awscli && \
    apk --purge -v del py-pip && \
    rm /var/cache/apk/*

# Add our app server daemon
RUN mkdir -p /etc/service/app
ADD docker-app.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run

# Make sure we start up in the app directory
WORKDIR /app
