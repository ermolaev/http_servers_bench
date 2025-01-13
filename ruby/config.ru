# frozen_string_literal: true
RubyVM::YJIT.enable
require 'rack'
hello = "Hello World #{ENV["SERVER"]} VER=#{RUBY_VERSION} YJIT=#{RubyVM::YJIT.enabled?}"

run lambda { |env|
  request = Rack::Request.new(env)

  delay = request.params['delay'].to_f
  sleep delay if delay > 0

  [200, { "Content-Type" => "text/plain" }, ["#{hello} delay=#{delay}"]]
}