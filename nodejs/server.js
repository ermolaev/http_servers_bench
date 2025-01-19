const http = require('http');
const { Pool } = require('pg');
const url = require('url');

// PostgreSQL connection pool
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'db1',
  user: 'user',
  password: 'pass',
  max: 20,
  idleTimeoutMillis: 5000,
  application_name: 'nodejs'
});

const NODE_VERSION = process.version;
const hello = `Hello World NodeJS VER=${NODE_VERSION}`;

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const params = parsedUrl.query;

  const { cpu, delay, count } = params;

  if (cpu) {
    for (let i = 0; i < 100_000_000; i++) {
      Math.sqrt(i * 99); // Example operation
    }
  }

  let pgRand = null;
  const delaySeconds = parseFloat(delay) || 0;
  const iterations = parseInt(count, 10) || 1;

  if (delaySeconds > 0) {
    try {
      for (let i = 0; i < iterations; i++) {
        const result = await pool.query(
          'SELECT random(1, 1_00_000) AS id, pg_sleep($1)',
          [delaySeconds]
        );
        pgRand = result.rows[0]?.id;
      }
    } catch (err) {
      console.error('Database error:', err);
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      return res.end('Internal Server Error');
    }
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(`${hello} delay=${delaySeconds} ${pgRand}`);
});

const PORT = process.env.PORT;
server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
