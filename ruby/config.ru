# frozen_string_literal: true

require 'rack'
require 'connection_pool'
require 'pg'

PG_POOL = ConnectionPool.new(size: 50, timeout: 5) do
  PG.connect('localhost', 5432, nil, nil, 'db1', 'user', 'pass')
end

# RubyVM::YJIT.enable
hello = "Hello World #{ENV["SERVER"]} VER=#{RUBY_VERSION} YJIT=#{RubyVM::YJIT.enabled?}"

run lambda { |env|
  request = Rack::Request.new(env)

  delay = request.params['delay'].to_f

  if request.params['cpu']
    100_000_000.times { it * 99 }
  end

  pg_rand =
    if delay > 0
      PG_POOL.with { it.exec("select random(1, 1_00_000) id, pg_sleep(#{delay})").first['id'] }
    end

  [200, { "Content-Type" => "text/plain" }, ["#{hello} delay=#{delay} #{pg_rand}"]]
}