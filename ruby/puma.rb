# frozen_string_literal: true

port 3000
threads 4, 20
workers ENV.fetch("WORKERS").to_i
