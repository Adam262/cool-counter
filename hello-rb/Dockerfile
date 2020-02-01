FROM ruby:2.6.5-slim

MAINTAINER "Adam Barcan <abarcan@gmail.com>"

RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y telnet

ENV APP_HOME /usr/src/app/

WORKDIR $APP_HOME

# Install Gemfile + Gemfile.lock before rest of app files
# This way, changes to app code will preserve gem cache
COPY Gemfile Gemfile.lock $APP_HOME

RUN bundle install

COPY . $APP_HOME

EXPOSE 4567

CMD ["rackup", "--host", "0.0.0.0", "-p", "4567"]
