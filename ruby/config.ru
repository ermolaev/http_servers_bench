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

RubyVM::YJIT.enable

PG_POOL = ConnectionPool.new(size: 20, timeout: 5) do
  PG.connect('localhost', 5432, nil, nil, 'db1', 'user', 'pass')
end

PG_POOL2 = ConnectionPool.new(size: 20, timeout: 5) do
  PG.connect('localhost', 5432, nil, nil, 'db1', 'user', 'pass')
end


hello = "Hello World #{ENV["SERVER"]} VER=#{RUBY_VERSION} YJIT=#{1}"

run lambda { |env|
  request = Rack::Request.new(env)
  delay = request.params['delay'].to_f
  pg_rand = nil

  if env['PATH_INFO'] == '/db2'
    PG_POOL2.with { |c| pg_rand = c.exec_params("select random(1, 1_00_000) id, pg_sleep($1)", [delay]).first['id'] }
    return [200, { "Content-Type" => "text/plain" }, ["#{hello} DB2 delay=#{delay} #{pg_rand}"]]
  end

  100_000_000.times { it * 99 } if request.params['cpu']

  if delay > 0
    (request.params['count'] || 1).to_i.times do
      PG_POOL.with { pg_rand = it.exec_params("select random(1, 1_00_000) id, pg_sleep($1)", [delay]).first['id'] }
    end
  end

  [200, { "Content-Type" => "text/plain" }, ["#{hello} delay=#{delay} #{pg_rand}"]]
}
