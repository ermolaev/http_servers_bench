require "http/server"
require "pg"

db = DB.open "postgres://user:pass@localhost:5432/db1?max_idle_pool_size=40"

hello = "Hello World Crystal VER=#{Crystal::VERSION}"

server = HTTP::Server.new do |context|
    request = context.request
    query_params = request.query_params

    # CPU-bound work
    if query_params["cpu"]?
        100_000_000.times { |it| it * 99 }
    end

    delay = query_params["delay"]?.try &.to_f || 0.0
    pg_rand = nil

    if delay > 0
        count = (query_params["count"]?.try &.to_i || 1).to_i
        count.times do
            pg_rand = db.query_one("SELECT random(1, 1_00_000) as id, pg_sleep($1)", delay, &.read(Int32))
        end
    end

    context.response.content_type = "text/plain"
    context.response.print "#{hello} delay=#{delay} #{pg_rand}"
end

puts "Server running on http://0.0.0.0:3002"
server.listen("0.0.0.0", 3002, reuse_port: true)
