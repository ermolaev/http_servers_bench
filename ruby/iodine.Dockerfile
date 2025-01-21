FROM ruby:3.4

# Use Jemalloc
RUN apt-get update && \
    apt-get install -y --no-install-recommends libjemalloc2
ENV LD_PRELOAD=libjemalloc.so.2

COPY . .

RUN bundle config set with 'iodine'
RUN bundle install --jobs=8

CMD bundle exec iodine -p $PORT -w $WORKERS -t 1