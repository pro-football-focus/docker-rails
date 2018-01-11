FROM alpine:3.7
MAINTAINER Geoff Lane <geoff.lane@profootballfocus.com>

ENV RAILS_ENV "production"
ENV RACK_ENV "production"
# With LibreSSL, on alpine:3.5, puma 3.7+ compiles but fails when trying to
# call DH_set0_pqg. Note that it will compile and run fine if DISABLE_SSL is
# set at build time: https://github.com/puma/puma/issues/1181
ENV DISABLE_SSL "true"

# Install ruby and dependencies
RUN apk --update --upgrade --no-cache add \
    curl-dev ruby-dev build-base alpine-sdk coreutils postgresql-dev mysql-dev \
    zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev libffi-dev \
    ruby ruby-io-console ruby-json ruby-bigdecimal git yaml nodejs && \
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
