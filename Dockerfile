FROM fluent/fluentd:v0.14.21-onbuild
MAINTAINER Arik Kfir <arik@infolinks.com>
RUN apk add --update --virtual bash .build-deps sudo build-base ruby-dev && \
    gem install fluent-plugin-secure-forward fluent-plugin-loggly fluent-plugin-forest && \
    gem sources --clear-all apk del .build-deps && \
    rm -rf /var/cache/apk/* /home/fluent/.gem/ruby/2.3.0/cache/*.gem
