FROM ruby:3.4

RUN gem install puma
RUN gem install rack
RUN gem install connection_pool
RUN gem install pg

COPY puma.rb /puma.rb
COPY config.ru /config.ru

EXPOSE 3000

CMD ["puma", "-C", "puma.rb", "config.ru"]
