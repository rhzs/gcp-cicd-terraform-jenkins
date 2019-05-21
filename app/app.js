const http = require('http');
const os = require("os");
const bind = '0.0.0.0';
const port = process.argv[2] || 5000;

const version = '1.6';

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end(
    JSON.stringify({
      data: 'welcome',
      version: version,
      build: process.argv[3],
      lang: 'js',
      hostname: os.hostname(),
    })
  );
});

server.listen(port, bind, () => {
  console.log(`Server running at http://${bind}:${port}/`)
})
