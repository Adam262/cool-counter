FROM ruby:2.6.5-slim

MAINTAINER "Adam Barcan <abarcan@gmail.com>"

ENV APP_HOME /usr/src/app/

WORKDIR $APP_HOME

COPY . $APP_HOME

RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl

RUN bundle install

EXPOSE 4567

CMD ["rackup", "--host", "0.0.0.0", "-p", "4567"]
