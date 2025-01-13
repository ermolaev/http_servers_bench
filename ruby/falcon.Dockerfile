FROM ruby:3.4

RUN gem install falcon

EXPOSE 3001

CMD ["falcon", "host"]
