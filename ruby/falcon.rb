#!/usr/bin/env -S falcon host
# frozen_string_literal: true
load :rack
hostname = File.basename(__dir__)
port = ENV["PORT"] || 3001
rack hostname do
  count ENV.fetch("WORKERS").to_i
  endpoint Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}").with(
    protocol: Async::HTTP::Protocol::HTTP11
  )
end
