FROM ruby:3.4

COPY . .

RUN bundle config set with 'puma'
RUN bundle install --jobs=8

EXPOSE 3000

CMD bundle exec puma -C puma.rb 
