# frozen_string_literal: true

# fork_worker 10_000

port 3000
threads 4, 32
workers ENV.fetch("WORKERS").to_i
