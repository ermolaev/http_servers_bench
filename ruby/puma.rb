# frozen_string_literal: true

port ENV.fetch("PORT")
threads 4, 10
workers ENV.fetch("WORKERS").to_i
