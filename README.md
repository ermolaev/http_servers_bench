
- `--no-attach kamal-proxy` for disable logs in console
- `network_mode: host` for disable docker-proxy
- limit for each container set to 2 CPUs
- can only be run on Linux, MacOS does not support `network_mode: host`

```bash
docker compose up
# show pg connection per application
docker compose exec postgres psql -U user -d db1 -c "SELECT application_name, count(*) FROM pg_stat_activity group by 1;"
# CPU, MEM utilization
docker compose stats
```

Benchmarked by [Oha](https://github.com/hatoo/oha)

### Bench program languages

Emulate real web example - 3 query in postgres (each query time - 2mc)

```bash
oha -n 20000 -c 50 -m GET "http://localhost:3000?count=3&delay=0.002" # ruby puma
oha -n 20000 -c 50 -m GET "http://localhost:3001?count=3&delay=0.002" # ruby falcon
oha -n 20000 -c 50 -m GET "http://localhost:3002?count=3&delay=0.002" # ruby iodine fiber
oha -n 20000 -c 50 -m GET "http://localhost:4000?count=3&delay=0.002" # crystal
oha -n 20000 -c 50 -m GET "http://localhost:4001?count=3&delay=0.002" # go
oha -n 20000 -c 50 -m GET "http://localhost:4002?count=3&delay=0.002" # nodejs
oha -n 20000 -c 50 -m GET "http://localhost:4003?count=3&delay=0.002" # async python
```
|                   | ruby puma| ruby falcon | ruby iodine | crystal | go   | nodejs | python |
|-------------------|----------|-------------|-------------|---------|------|--------|--------|
| Requests/sec:     | 3179     | 4943        | 3543        | 7549    | 5996 | 5510   | 2731   |
| Percentile 50% mc | 10       | 10          | 7           | 6       | 8    | 9      | 18     |
| Percentile 90% mc | 27       | 12          | 28          | 7       | 9    | 10     | 20     |
| Percentile 99% mc | 68       | 14          | 45          | 7       | 9    | 13     | 23     |
| CPU utilization % | 218      | 186         | 206         | 70      | 165  | 199    | 206    |
| Memory (MiB)      | 74       | 71          | 227         | 14      | 14   | 99     | 60     |

### Puma vs Falcon vs iodine, different connections

```bash
oha -n 20000 -c 50 -m GET "http://localhost:3000?count=3&delay=0.002" # ruby puma
oha -n 20000 -c 50 -m GET "http://localhost:3001?count=3&delay=0.002" # ruby falcon
oha -n 20000 -c 50 -m GET "http://localhost:3002?count=3&delay=0.002" # ruby iodine
```
##### Requests/sec
| connections       | ruby puma| ruby falcon | ruby iodine |
|-------------------|----------|-------------|-------------|
| -c 50             | 3179     | 4943        | 3543        |
| -c 200            | 3083     | 4066        | 561         |
| -c 500            | 2970     | 2909        | 244         |

##### Percentile 90%, mc
| connections       | ruby puma| ruby falcon | ruby iodine |
|-------------------|----------|-------------|-------------|
| -c 50             | 10       | 10          | 7           |
| -c 200            | 27       | 55          | 257         |
| -c 500            | 29       | 193         | 5097        |

Iodine with 200 and 500 connections have many error with db poll - 
`ERROR: Iodine caught an unprotected exception - ConnectionPool::TimeoutError: Waited 5 sec, 0/20 available`

### Ruby vs Nodejs vs Python, switch context workers on 2 cpu, pg pool size - 20 per worker
| workers | ruby puma | ruby falcon | nodejs | python |
|---------|-----------|-------------|--------|--------|
| 2       | 3179      | 4943        | 5510   | 2731   |
| 3       | 3133      | 5251        | 5442   | 2114   |
| 4       | 3396      | 4789        | 4784   | 1962   |
| 7       | 4851      | 4376        | 4056   | 1827   |
| 15      | 5088      | 4373        | 2242   | 1579   |