FROM ruby:2.6.9
RUN apt-get update -qq && apt-get install -y nodejs default-libmysqlclient-dev yarn build-essential libpq-dev 
WORKDIR /myapp
COPY . /myapp/
RUN gem install bundler && bundle install

EXPOSE 3002