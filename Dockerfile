FROM alpine:3.5
MAINTAINER Jake Weaver <jake.weaver@profootballfocus.com>

ENV RAILS_ENV "production"
ENV RACK_ENV "production"
# With LibreSSL, on alpine:3.5, puma 3.7+ compiles but fails when trying to
# call DH_set0_pqg. Note that it will compile and run fine if DISABLE_SSL is
# set at build time: https://github.com/puma/puma/issues/1181
ENV DISABLE_SSL "true"

RUN apk --update --upgrade add \
    curl-dev ruby2.2-dev build-base alpine-sdk coreutils postgresql-dev mysql-dev \
    zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev libffi-dev \
    ruby2.2 ruby2.2-io-console ruby2.2-bigdecimal ruby2.2-json git yaml nodejs && \
    ln -s /usr/bin/ruby2.2 /usr/bin/ruby && \
    ln -s /usr/bin/gem2.2 /usr/bin/gem && \
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
