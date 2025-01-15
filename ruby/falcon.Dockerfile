FROM ruby:3.4

RUN gem install falcon
RUN gem install connection_pool
RUN gem install pg

EXPOSE 3001

CMD ["falcon", "host"]
