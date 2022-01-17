FROM ruby:2.6.9
RUN apt-get update -qq && apt-get install -y nodejs default-libmysqlclient-dev yarn build-essential libpq-dev 
WORKDIR /myapp
COPY . /myapp/
RUN gem install bundler && bundle install

# Add a script to be executed every time the container starts.
EXPOSE 3003

# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]