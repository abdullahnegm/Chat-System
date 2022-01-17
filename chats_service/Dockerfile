FROM ruby:2.6.9
RUN apt-get update -qq && apt-get install -y nodejs default-libmysqlclient-dev yarn build-essential libpq-dev 
WORKDIR /myapp
COPY . /myapp/
RUN gem install bundler && bundle install

# Add a script to be executed every time the container starts.
# COPY tasks.sh /usr/bin/
# RUN chmod +x /usr/bin/tasks.sh

# ENTRYPOINT ["tasks.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
# CMD ["rails", "server", "-p", "3001"]