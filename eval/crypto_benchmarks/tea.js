const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSTea = require('./tea/tea.js');
const outdir = process.argv[2];
function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/tea/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchHandWasmTea(is_sec, bytes, rounds, key, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const memory = new WebAssembly.Memory({initial: 1, secret: is_sec});
  const tea = await instance((is_sec ? "sec" : "pub") + "_tea.wasm", {js: {memory}});
  const mem = new Uint32Array(memory.buffer);

  // message
  mem[0] = message[0];
  mem[1] = message[1];
  // key
  mem[2] = key[0];
  mem[3] = key[1];
  mem[4] = key[2];
  mem[5] = key[3];

  let measurements = new Array();

  /* run */
  for (let i = 0; i < rounds; i++) {
    //mem[0] = message[0];
    //mem[1] = message[1];
    measurements.push(rdtscp());
    tea.instance.exports.encrypt();
  }
  measurements.push(rdtscp());

  const output = [mem[0], mem[1]];

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchJSTea(bytes, rounds, key, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  var output;
  let measurements = new Array();

  JSTea.init(() => {
    const warmup = 10000;

    /* warmup */
    for (let i = 0; i < warmup; i++) {
      JSTea.encrypt(message, key);
    }

    /* run */
    for (let i = 0; i < rounds; i++) {
      measurements.push(rdtscp());
      output = JSTea.encrypt(message, key);
    }
    measurements.push(rdtscp());
  });

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const key_len = 16;
  const bytes = 8;
  const rounds = 10000;
  const max = 0xffffffff;

  let message = new Uint32Array(bytes / 4);
  for (let i = 0; i < (bytes / 4); i++) {
    message[i] = getRand(max);
  }
  let key = new Uint32Array(key_len / 4);
  for (let i = 0; i < (key_len / 4); i++) {
    key[i] = getRand(max);
  }

  const handwasmpub_res = await benchHandWasmTea(false, bytes, rounds, key, message).catch(err => console.log(err));
  const handwasm_res = await benchHandWasmTea(true, bytes, rounds, key, message).catch(err => console.log(err));
  const js_res = await benchJSTea(bytes, rounds, key, message).catch(err => console.log(err));

  await promisify(fs.writeFile)(`${outdir}/hand.measurements`, handwasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/handpub.measurements`, handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/js.measurements`, js_res[0].join('\n') + '\n');

  /*assert.deepEqual(handwasm_res[1], js_res[1]);
  assert.deepEqual(handwasmpub_res[1], js_res[1]);*/
}

benchDriver().catch(err => console.log(err));
