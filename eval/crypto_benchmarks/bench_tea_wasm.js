const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/tea/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchmarkDriver(is_sec) {
  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 10;

  let memory = new WebAssembly.Memory({ initial: 1, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance((is_sec ? "sec" : "strip") + "_tea.wasm", { js: { memory } });
  let e = s.instance.exports;

  mem[0] = 0;
  mem[1] = 0;

  let classes = new Array();
  for (let i = 0; i < number_measurements; i++) {
    classes.push(getRand(2));
  }

  let keys = new Array();
  for (let i = 0; i < number_measurements; i++) {
    keys.push(new Uint8Array(bytes));
    if (classes[i] == 0) {
      for (let j = 0; j < 16; j++) {
        keys[i][j] = 0;
      }
    } else {
      for (let j = 0; j < 16; j++) {
        keys[i][j] = getRand(0xff);
      }
    }
  }

  let measurements = new Array();

  for (let i = 0; i < number_measurements; i++) {
    measurements.push(rdtscp());

    for (let j = 0; j < 16; j++) {
      mem8[8 + j] = keys[i][j];
    }

    for (let j = 0; j < rounds; j++) {
      e.encrypt(bytes);
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

const is_stripped = process.argv[2] == "--stripped";

benchmarkDriver(!is_stripped).catch(err => console.log(err));
