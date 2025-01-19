const cluster = require('node:cluster');
const { availableParallelism } = require('node:os');
const numCPUs = availableParallelism();

if (numCPUs > 1 && cluster.isPrimary) {
  console.log(`Primary ${process.pid} is running`);

  // Fork workers.
  for (let i = 0; i < 2; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`worker ${worker.process.pid} died`);
    process.exit(1);
  });
} else {
  // Task for forked worker
  require('./server');
}