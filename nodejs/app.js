const cluster = require('node:cluster');
const { availableParallelism } = require('node:os');
// const numCPUs = availableParallelism();
// numCPUs not correct inside the docker container with cpus limited
// https://github.com/nodejs/node/issues/28762

const numCPUs = parseInt(process.env.WORKERS, 10)
if (numCPUs > 1 && cluster.isPrimary) {
  console.log(`Primary ${process.pid} is running`);

  // Fork workers.
  for (let i = 0; i < numCPUs; i++) {
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