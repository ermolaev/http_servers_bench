# frozen_string_literal: true

require 'rack'
require 'connection_pool'
require 'pg'

if ENV["SERVER"] == "iodine"
  require 'rage'
  require 'rage/fiber'
  require 'rage/fiber_scheduler'
  require 'rage/middleware/fiber_wrapper'
  use Rage::FiberWrapper
end

PG_POOL = ConnectionPool.new(size: 20, timeout: 5) do
  PG.connect('localhost', 5432, nil, nil, 'db1', 'user', 'pass')
end

RubyVM::YJIT.enable
hello = "Hello World #{ENV["SERVER"]} VER=#{RUBY_VERSION} YJIT=#{RubyVM::YJIT.enabled?}"

run lambda { |env|
  request = Rack::Request.new(env)

  100_000_000.times { it * 99 } if request.params['cpu']

  delay = request.params['delay'].to_f
  pg_rand = nil

  if delay > 0
    (request.params['count'] || 1).to_i.times do
      PG_POOL.with { pg_rand = it.exec_params("select random(1, 1_00_000) id, pg_sleep($1)", [delay]).first['id'] }
    end
  end

  [200, { "Content-Type" => "text/plain" }, ["#{hello} delay=#{delay} #{pg_rand}"]]
}
