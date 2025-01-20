import multiprocessing
import os

workers = int(os.getenv("WORKERS"))

bind = f"0.0.0.0:{os.getenv("PORT")}"
keepalive = 120
pidfile = '/tmp/uvicorn.pid'
worker_class = "uvicorn_worker.UvicornWorker"