FROM ruby:3.4

# Use Jemalloc
RUN apt-get update && \
    apt-get install -y --no-install-recommends libjemalloc2
ENV LD_PRELOAD=libjemalloc.so.2

RUN gem install connection_pool
RUN gem install pg
RUN gem install rage-rb

CMD iodine -p $PORT -w $WORKERS -t 1