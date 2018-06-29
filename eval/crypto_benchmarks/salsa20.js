const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSSalsa20 = require('js-salsa20');
const outdir = process.argv[2];

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/salsa20/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchHandWasmSalsa20(is_sec, bytes, rounds, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  /* compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 2, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance((is_sec ? "sec" : "pub") + "_salsa20.wasm", { js: { memory } });
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);
  const key_size = 8;
  const iv_size = 2;

  /* key setup */
  let k = new Uint32Array(key_size);
  for (let i = 0, j = 0; i < key_size; i++, j += 4) {
    k[i] = (key[j+3] << 24)
      | (key[j+2] << 16)
      | (key[j+1] << 8)
      | (key[j] << 0);
  }
  e.keysetup(k[0], k[1], k[2], k[3], k[4], k[5], k[6], k[7]);

  /* nonce setup */
  let n = new Uint32Array(iv_size);
  for (let i = 0, j = 0; i < iv_size; i++, j += 4) {
    n[i] = (nonce[j+3] << 24)
      | (nonce[j+2] << 16)
      | (nonce[j+1] << 8)
      | (nonce[j] << 0);
  }
  e.noncesetup(n[0], n[1]);

  /* ciphertext range */
  const c_start = 32 * 4;
  const c_end = c_start + bytes;

  /* message setup */
  const m_start = c_end;
  const m_end = m_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[m_start + i] = message[i];
  }

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.encrypt(bytes);
  }
  measurements.push(rdtscp());

  const output = mem8.slice(c_start, c_end);

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchJSSalsa20(bytes, rounds, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const warmup = 10000;

  /* setup and run */
  const ew = new JSSalsa20(key, nonce);

  /* warmup */
  for (let i = 0; i < warmup; i++) {
    ew.encrypt(message);
  }

  /* setup and run */
  const e = new JSSalsa20(key, nonce);

  var output;
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    output = e.encrypt(message);
  }
  measurements.push(rdtscp());

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const key_len = 32;
  const nonce_len = 8;
  const bytes = 4096;
  const rounds = 10000;
  const max = 0xff;

  const key = new Uint8Array(key_len);
  for (let i = 0; i < key_len; i++) {
    key[i] = getRand(max);
  }
  const nonce = new Uint8Array(nonce_len);
  for (let i = 0; i < nonce_len; i++) {
    nonce[i] = getRand(max);
  }
  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = getRand(max);
  }

  const handwasm_res = await benchHandWasmSalsa20(true, bytes, rounds, key, nonce, message).catch(err => console.log(err));
  const handwasmpub_res = await benchHandWasmSalsa20(false, bytes, rounds, key, nonce, message).catch(err => console.log(err));
  const js_res = await benchJSSalsa20(bytes, rounds, key, nonce, message).catch(err => console.log(err));

  await promisify(fs.writeFile)(`${outdir}/hand.measurements`, handwasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/handpub.measurements`, handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/js.measurements`, js_res[0].join('\n') + '\n');

  assert.deepEqual(handwasm_res[1], js_res[1]);
  assert.deepEqual(handwasmpub_res[1], js_res[1]);
}

benchDriver().catch(err => console.log(err));
