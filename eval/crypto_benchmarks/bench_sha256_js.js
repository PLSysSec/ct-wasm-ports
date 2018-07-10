const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');
const shajs = require('sha.js');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function benchmarkDriver() {
  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 1;
  const warmup = 100;

  let classes = new Array();
  for (let i = 0; i < number_measurements; i++) {
    classes.push(getRand(2));
  }

  let messages = new Array();
  for (let i = 0; i < number_measurements; i++) {
    messages.push(new Uint8Array(bytes));
    if (classes[i] == 0) {
      for (let j = 0; j < bytes; j++) {
        messages[i][j] = 0;
      }
    } else {
      for (let j = 0; j < bytes; j++) {
        messages[i][j] = getRand(0xff);
      }
    }
  }

  var js_obj = new shajs.sha256();

  let measurements = new Array();

  for (let i = 0; i < warmup; i++) {
    js_obj.update(messages[0]);
  }

  for (let i = 0; i < number_measurements; i++) {
    measurements.push(rdtscp());
    for (let i = 0; i < rounds; i++) {
      js_obj.update(messages[i]);
    }
  }
  measurements.push(rdtscp());

  fs.writeFile('params.log',
    [number_measurements].join('\n') + '\n',
    err => { if (err) throw err; });

  fs.writeFile('classes.log',
    classes.join('\n') + '\n',
    err => { if (err) throw err; });

  fs.writeFile('output.log',
    measurements.map(m => new int64(m[1], m[0]).toOctetString()).join('\n') + '\n',
    err => { if (err) throw err; });
}

benchmarkDriver().catch(err => console.log(err));
