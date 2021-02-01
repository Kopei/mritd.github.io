FROM ruby:2.7.0-alpine

ENV TZ 'Asia/Shanghai'

WORKDIR /root

ADD Gemfile ./
RUN apk upgrade --no-cache && \
    apk add --no-cache bash tzdata nodejs py-pygments git gcc musl-dev make g++ && \
    gem install --no-document bundle && \
    bundle install && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del gcc musl-dev make && \
    rm -rf /var/cache/apk/*

#ADD cron/15min/* /etc/periodic/15min

ADD . .

CMD ["/root/entrypoint.sh"]
