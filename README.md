
- `--no-attach kamal-proxy` for disable logs in console
- `network_mode: host` for disable docker-proxy
- limit for all containers set to 2 CPUs
- can only be run on Linux, MacOS does not support `network_mode: host`

```bash
docker compose up --build --no-attach kamal-proxy

docker compose exec kamal-proxy kamal-proxy deploy go      --target localhost:3003 --host go.localhost
docker compose exec kamal-proxy kamal-proxy deploy puma    --target localhost:3000 --host puma.localhost
docker compose exec kamal-proxy kamal-proxy deploy falcon  --target localhost:3001 --host falcon.localhost
docker compose exec kamal-proxy kamal-proxy ls

docker compose exec postgres psql -U user -d db1 -c "SELECT application_name, count(*) FROM pg_stat_activity group by 1;"
```

Benchmarked by [Oha](https://github.com/hatoo/oha)

## Direct
```bash
oha -n 100000 -c 200 -m GET http://puma.localhost:3000
oha -n 100000 -c 200 -m GET http://falcon.localhost:3001
oha -n 100000 -c 200 -m GET http://go.localhost:3003
```

## Nginx
```bash
oha -n 100000 -c 200 -m GET http://puma.localhost
oha -n 100000 -c 200 -m GET http://falcon.localhost
oha -n 100000 -c 200 -m GET http://go.localhost
```

## Kamal Proxy
```bash
oha -n 100000 -c 200 -m GET http://puma.localhost:8080
oha -n 100000 -c 200 -m GET http://falcon.localhost:8080
oha -n 100000 -c 200 -m GET http://go.localhost:8080
```


## Results delay = 0

### Puma

|                   | puma   | puma -> nginx <br/> keepalive 32  | puma -> nginx <br/> keepalive 100  | puma -> kamal-proxy |
|-------------------|--------|----------------|----------------|---------------------|
| Requests/sec:     | 17974  | 16241          | 15413          | 8996                |
| Percentile 10.00% | 0.0015 | 0.0017         | 0.0017         | 0.0026              |
| Percentile 25.00% | 0.0020 | 0.0021         | 0.0021         | 0.0032              |
| Percentile 50.00% | 0.0025 | 0.0026         | 0.0026         | 0.0038              |
| Percentile 75.00% | 0.0030 | 0.0030         | 0.0031         | 0.0047              |
| Percentile 90.00% | 0.0045 | 0.0047         | 0.0048         | 0.0086              |
| Percentile 95.00% | 0.0061 | 0.0079         | 0.0080         | 0.0343              |
| Percentile 99.00% | 0.4162 | 0.4317         | 0.4477         | 0.6152              |
| Percentile 99.90% | 0.4560 | 0.4769         | 0.5376         | 0.6886              |
| Percentile 99.99% | 0.4742 | 0.4997         | 0.5970         | 0.7178              |

### Falcon

|                   | falcon   | falcon -> nginx <br/> keepalive 32  | falcon -> nginx <br/> keepalive 100  | falcon -> kamal-proxy |
|-------------------|--------|---------|--------|---------|
| Requests/sec:     | 16874  | 13491   | 13964  |  7340   |
| Percentile 10.00% | 0.0098 | 0.0113  | 0.0108 |  0.0100 |
| Percentile 25.00% | 0.0106 | 0.0127  | 0.0123 |  0.0136 |
| Percentile 50.00% | 0.0114 | 0.0143  | 0.0141 |  0.0178 |
| Percentile 75.00% | 0.0124 | 0.0160  | 0.0160 |  0.0284 |
| Percentile 90.00% | 0.0136 | 0.0179  | 0.0178 |  0.0452 |
| Percentile 95.00% | 0.0147 | 0.0189  | 0.0192 |  0.0973 |
| Percentile 99.00% | 0.0175 | 0.0208  | 0.0226 |  0.1066 |
| Percentile 99.90% | 0.0305 | 0.0900  | 0.0284 |  0.2981 |
| Percentile 99.99% | 0.4505 | 0.5699  | 0.1341 |  0.5002 |

### Go

|                   | go   | go -> nginx <br/> keepalive 32  | go -> nginx <br/> keepalive 100  | go -> kamal-proxy |
|-------------------|--------|----------------|----------------|----------|
| Requests/sec:     | 57789  | 39264          | 49877          |  12245   |
| Percentile 10.00% | 0.0017 | 0.0023         | 0.0005         |  0.0021  |
| Percentile 25.00% | 0.0028 | 0.0055         | 0.0013         |  0.0038  |
| Percentile 50.00% | 0.0052 | 0.0129         | 0.0024         |  0.0066  |
| Percentile 75.00% | 0.0110 | 0.0406         | 0.0041         |  0.0116  |
| Percentile 90.00% | 0.0696 | 0.0675         | 0.0056         |  0.0662  |
| Percentile 95.00% | 0.0779 | 0.0790         | 0.0081         |  0.0705  |
| Percentile 99.00% | 0.0918 | 0.0983         | 0.0391         |  0.0765  |
| Percentile 99.90% | 0.1035 | 0.1430         | 0.0431         |  0.0833  |
| Percentile 99.99% | 0.1080 | 0.1944         | 0.0456         |  0.0895  |


## Results delay = 0.02

|                   | puma   | puma -> nginx <br/> keepalive 32  | puma -> nginx <br/> keepalive 100  | puma -> kamal-proxy |
|-------------------|--------|----------------|----------------|----------------|
| Requests/sec:     | 3058   | 3060           | 3055           | 3022    |
| Percentile 10.00% | 0.0202 | 0.0202         | 0.0202         | 0.0204  |
| Percentile 25.00% | 0.0202 | 0.0203         | 0.0203         | 0.0204  |
| Percentile 50.00% | 0.0202 | 0.0203         | 0.0203         | 0.0205  |
| Percentile 75.00% | 0.0205 | 0.0204         | 0.0204         | 0.0208  |
| Percentile 90.00% | 0.0218 | 0.0207         | 0.0215         | 0.0219  |
| Percentile 95.00% | 0.5548 | 0.5417         | 0.5483         | 0.5816  |
| Percentile 99.00% | 0.7516 | 0.5654         | 0.6324         | 0.7174  |
| Percentile 99.90% | 0.9954 | 0.6041         | 0.8599         | 0.8113  |
| Percentile 99.99% | 1.0194 | 0.7100         | 0.9037         | 0.8294  |


### Falcon

|                   | falcon   | falcon -> nginx <br/> keepalive 32  | falcon -> nginx <br/> keepalive 100  | falcon -> kamal-proxy |
|-------------------|--------|----------------|----------------|----------------|
| Requests/sec:     | 9571   | 9526           | 9430           |  7847    |
| Percentile 10.00% | 0.0202 | 0.0204         | 0.0204         |  0.0223  |
| Percentile 25.00% | 0.0204 | 0.0205         | 0.0205         |  0.0233  |
| Percentile 50.00% | 0.0207 | 0.0207         | 0.0209         |  0.0246  |
| Percentile 75.00% | 0.0212 | 0.0211         | 0.0215         |  0.0266  |
| Percentile 90.00% | 0.0218 | 0.0218         | 0.0223         |  0.0294  |
| Percentile 95.00% | 0.0221 | 0.0223         | 0.0228         |  0.0320  |
| Percentile 99.00% | 0.0229 | 0.0234         | 0.0238         |  0.0377  |
| Percentile 99.90% | 0.0302 | 0.0349         | 0.0335         |  0.0493  |
| Percentile 99.99% | 0.0348 | 0.0395         | 0.0453         |  0.0756  |

### Go

|                   | go   | go -> nginx <br/> keepalive 32  | go -> nginx <br/> keepalive 100  | go -> kamal-proxy |
|-------------------|--------|----------------|----------------|---------|
| Requests/sec:     | 58027  | 40964          | 49595          | 12397   |
| Percentile 10.00% | 0.0004 | 0.0006         | 0.0005         | 0.0021  |
| Percentile 25.00% | 0.0006 | 0.0012         | 0.0011         | 0.0038  |
| Percentile 50.00% | 0.0010 | 0.0024         | 0.0022         | 0.0066  |
| Percentile 75.00% | 0.0017 | 0.0048         | 0.0041         | 0.0114  |
| Percentile 90.00% | 0.0040 | 0.0075         | 0.0057         | 0.0660  |
| Percentile 95.00% | 0.0053 | 0.0128         | 0.0078         | 0.0698  |
| Percentile 99.00% | 0.0644 | 0.0453         | 0.0411         | 0.0756  |
| Percentile 99.90% | 0.0674 | 0.0498         | 0.0455         | 0.0813  |
| Percentile 99.99% | 0.0694 | 0.0527         | 0.0478         | 0.0869  |
