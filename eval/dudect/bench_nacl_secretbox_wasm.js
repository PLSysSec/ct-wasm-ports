const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

const is_stripped = process.argv[2] == "--stripped";
const nacl = require('../node_tweetnacl/' + ((!is_stripped) ? 'nacl-ctwasm.js' : 'nacl-stripped-wasm.js'));

async function benchmarkDriver() {

  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 10;

  const key_size = 32;
  const iv_size = 24;

  const nonce = new Uint8Array(iv_size);
  for (let i = 0; i < iv_size; i++) {
    nonce[i] = 0;
  }

  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = 0;
  }

  let classes = new Array();
  for (let i = 0; i < number_measurements; i++) {
    classes.push(getRand(2));
  }

  let keys = new Array();
  for (let i = 0; i < number_measurements; i++) {
    keys.push(new Uint8Array(key_size));
    if (classes[i] == 0) {
      for (let j = 0; j < key_size; j++) {
        keys[i][j] = 0;
      }
    } else {
      for (let j = 0; j < key_size; j++) {
        keys[i][j] = getRand(0xff);
      }
    }
  }

  let measurements = new Array();

  for (let i = 0; i < number_measurements; i++) {
    measurements.push(rdtscp());

    for (let i = 0; i < rounds; i++) {
      nacl.secretbox(message, nonce, keys[i]);
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

nacl.instanceReady().then(() =>
  benchmarkDriver()).catch(err => console.log(err));
