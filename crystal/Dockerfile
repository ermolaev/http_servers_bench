FROM crystallang/crystal:latest
COPY . .
RUN shards install

RUN crystal build server.cr --release --no-debug

CMD bash run.sh