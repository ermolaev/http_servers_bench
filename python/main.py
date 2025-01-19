import os
import asyncio
import asyncpg
from uvicorn import Config, Server
from urllib.parse import parse_qs

hello = f"Hello World Python VER={os.sys.version}"

async def setup():
    global pg_pool
    pg_pool = await asyncpg.create_pool(
        user='user',
        password='pass',
        database='db1',
        host='localhost',
        port=5432,
        min_size=1,
        max_size=20,
        server_settings={'application_name': 'python'}
    )


pg_pool = None

async def handler(scope, receive, send):
    if scope["type"] == "http":
        query_string = scope.get('query_string', b'').decode()
        query_params = parse_qs(query_string)

        cpu_work = 'cpu' in query_params
        delay = float(query_params.get('delay', [0])[0])  # Default to 0 if not found
        count = int(query_params.get('count', [1])[0])  # Default to 1 if not found

        pg_rand = None
        if delay > 0:
            for _ in range(count):
                async with pg_pool.acquire() as conn:
                    result = await conn.fetchrow("SELECT random(1, 1_00_000) AS id, pg_sleep($1)", delay)
                    pg_rand = result['id']

        response = f"{hello} delay={delay} {pg_rand}"

        await send({
            "type": "http.response.start",
            "status": 200,
            "headers": [
                [b"content-type", b"text/plain"],
            ],
        })
        await send({
            "type": "http.response.body",
            "body": response.encode(),
        })

async def app(scope, receive, send):
    if scope['type'] == 'lifespan':
        message = await receive()
        if message['type'] == 'lifespan.startup':
            await setup()
            await send({'type': 'lifespan.startup.complete'})
    await handler(scope, receive, send)
