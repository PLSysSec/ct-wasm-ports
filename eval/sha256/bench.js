const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSSha256 = require('sha.js');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchHandWasmSha256(is_sec, bytes, rounds, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } 

  /* compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 1, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance((is_sec ? "sec" : "pub") + "_sha256.wasm", { js: { memory } });
  let e = s.instance.exports;

  const karr_base = 88;
  const hash_base = 608;
  const hash_len = 32;
  const input_base = 640;

  /* load k array */
  const k = [
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
  ];
  for (let i = 0; i < 64; i++) {
    mem[karr_base + i] = k[i];
  }

  for (let i = 0; i < bytes; i++) {
    mem8[input_base + i] = message[i];
  }

  /* setup */
  e.init();

  /* run */
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.update(bytes);
  }
  e.final();
  measurements.push(rdtscp());

  const preout = mem8.slice(hash_base, hash_base + hash_len);

  /* format output */
  let out = Array(32);
  let x;
  for (let i = 0; i < hash_len; i++) {
    x = preout[i].toString(16);
    if (x == 0) out[i] = "00";
    else if (x == 1) out[i] = "01";
    else if (x == 2) out[i] = "02";
    else if (x == 3) out[i] = "03";
    else if (x == 4) out[i] = "04";
    else if (x == 5) out[i] = "05";
    else if (x == 6) out[i] = "06";
    else if (x == 7) out[i] = "07";
    else if (x == 8) out[i] = "08";
    else if (x == 9) out[i] = "09";
    else if (x == "a") out[i] = "0a";
    else if (x == "b") out[i] = "0b";
    else if (x == "c") out[i] = "0c";
    else if (x == "d") out[i] = "0d";
    else if (x == "e") out[i] = "0e";
    else if (x == "f") out[i] = "0f";
    else out[i] = x;
  }

  const output = out.join("");

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchJSSha256(bytes, rounds, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const warmup = 10000;

  /* setup and run */
  const ew = new JSSha256.sha256();

  /* warmup */
  for (let i = 0; i < warmup; i++) {
    ew.update(message);
  }

  /* setup and run */
  const e = new JSSha256.sha256();

  var output;
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    output = e.update(message);
  }
  measurements.push(rdtscp());

  output = output.digest('hex');

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const bytes = 4096;
  const rounds = 10000;
  const max = 0xff;

  let message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = getRand(max);
  }

  const handwasm_res = await benchHandWasmSha256(true, bytes, rounds, message).catch(err => console.log(err));
  const handwasmpub_res = await benchHandWasmSha256(false, bytes, rounds, message).catch(err => console.log(err));
  const js_res = await benchJSSha256(bytes, rounds, message).catch(err => console.log(err));

  await promisify(fs.writeFile)('hand.measurements', handwasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('handpub.measurements', handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('js.measurements', js_res[0].join('\n') + '\n');

  assert.deepEqual(handwasm_res[1], js_res[1]);
  assert.deepEqual(handwasmpub_res[1], js_res[1]);
}

benchDriver().catch(err => console.log(err));
