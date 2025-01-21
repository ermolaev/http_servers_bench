FROM ruby:3.4

COPY . .

RUN bundle config set with 'falcon'
RUN bundle install --jobs=8

EXPOSE 3001

CMD bundle exec falcon host
