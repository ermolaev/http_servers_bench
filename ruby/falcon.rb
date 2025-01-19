#!/usr/bin/env -S falcon host
# frozen_string_literal: true
load :rack
hostname = File.basename(__dir__)
rack hostname do
  count ENV.fetch("WORKERS").to_i
  endpoint Async::HTTP::Endpoint.parse("http://0.0.0.0:#{ENV.fetch("PORT")}").with(
    protocol: Async::HTTP::Protocol::HTTP11
  )
end
