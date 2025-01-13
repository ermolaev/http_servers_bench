docker compose up --build


docker compose exec kamal-proxy kamal-proxy deploy go      --target localhost:3003
docker compose exec kamal-proxy kamal-proxy deploy go-port --target localhost:3003 --host go.localhost
docker compose exec kamal-proxy kamal-proxy deploy puma    --target localhost:3000 --host puma.localhost
docker compose exec kamal-proxy kamal-proxy deploy falcon  --target localhost:3001 --host falcon.localhost
docker compose exec kamal-proxy kamal-proxy ls


oha -n 5000 -c 100 -m GET http://localhost:8080/puma
oha -n 5000 -c 100 -m GET http://localhost:8080/falcon
oha -n 5000 -c 100 -m GET http://localhost:8080/hello
oha -n 5000 -c 100 -m GET http://localhost:8080/go --disable-keepalive
