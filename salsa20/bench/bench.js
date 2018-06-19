const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSSalsa20 = require('js-salsa20');

function abort (what) {
  throw "abort: " + what;
}

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchWasmSalsa20(bytes, rounds, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } else if (bytes > 15984) {
    throw new Error('Current max number of bytes surpassed! Current behavior is undefined. Increase wasm memory.');
  }

  /* Compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 256 });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let table = new WebAssembly.Table({ initial: 8, element: "anyfunc" });
  let s = await instance("../reference/salsa20.O2.wasm",
    {
      env: {
        memory,
        table,
        memoryBase: 0,
        tableBase: 0,
        abort,
        _memset: function(p, k, n) {
          for (let i = 0; i < n; i++) {
            mem[(p/4) + i] = k;
          }
        }
      },
      global: { NaN, Infinity, },
    }
  );
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);
  const ctx_size = 16;
  const key_size = 8;
  const iv_size = 2;

  /* ctx range */
  const ctx_start = 64;
  const ctx_end = ctx_start + ctx_size * 4;

  /* key setup */
  const k_start = ctx_end;
  const k_end = k_start + key_size * 4;
  const kbits = 256;
  for (let i = 0; i < key_size * 4; i++) {
    mem8[k_start + i] = key[i];
  }

  /* iv setup */
  const iv_start = k_end;
  const iv_end = iv_start + iv_size * 4;
  const ivbits = 64; // unused in implementation?
  for (let i = 0; i < iv_size * 4; i++) {
    mem8[iv_start + i] = nonce[i];
  }

  /* message setup */
  const m_start = iv_end;
  const m_end = m_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[m_start + i] = message[i];
  }

  /* ciphertext range */
  const c_start = m_end;
  const c_end = c_start + bytes;

  e._ECRYPT_keysetup(ctx_start, k_start, kbits, ivbits);
  e._ECRYPT_ivsetup(ctx_start, iv_start);

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e._ECRYPT_encrypt_bytes(ctx_start, m_start, c_start, bytes);
  }
  measurements.push(rdtscp());

  return measurements.map(x => new int64(x[1], x[0]).toOctetString());
}

async function benchHandWasmSalsa20(is_sec, bytes, rounds, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } else if (bytes > 15984) {
    throw new Error('Current max number of bytes surpassed! Current behavior is undefined. Increase wasm memory.');
  }

  /* Compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 2, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance("../ct/" + (is_sec ? "sec" : "pub") + "_salsa20_stack.wasm", { js: { memory } });
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);
  const key_size = 8;
  const iv_size = 2;

  /* Key setup */
  let k = new Uint32Array(key_size);
  for (let i = 0, j = 0; i < key_size; i++, j += 4) {
    k[i] = (key[j+3] << 24)
      | (key[j+2] << 16)
      | (key[j+1] << 8)
      | (key[j] << 0);
  }
  e.keysetup(k[0], k[1], k[2], k[3], k[4], k[5], k[6], k[7]);

  /* Nonce setup */
  let n = new Uint32Array(iv_size);
  for (let i = 0, j = 0; i < iv_size; i++, j += 4) {
    n[i] = (nonce[j+3] << 24)
      | (nonce[j+2] << 16)
      | (nonce[j+1] << 8)
      | (nonce[j] << 0);
  }
  e.noncesetup(n[0], n[1]);

  /* message setup */
  const m_start = 16016 * 4;
  const m_end = m_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[m_start + i] = message[i];
  }

  /* ciphertext range */
  const c_start = 32 * 4;
  const c_end = c_start + bytes;

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.encrypt(bytes);
  }
  measurements.push(rdtscp());

  return measurements.map(x => new int64(x[1], x[0]).toOctetString());
}

async function benchJSSalsa20(bytes, rounds, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const warmup = 10000;

  /* Setup and run */
  const e = new JSSalsa20(key, nonce);

  /* Warmup */
  for (let i = 0; i < warmup; i++) {
    e.encrypt(message);
  }

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.encrypt(message);
  }
  measurements.push(rdtscp());

  return measurements.map(x => new int64(x[1], x[0]).toOctetString());
}

async function benchDriver() {
  const key_len = 32;
  const nonce_len = 8;
  const bytes = 4096;
  const rounds = 10000;

  const key = new Uint8Array(key_len);
  for (let i = 0; i < key_len; i++) {
    key[i] = 0;
  }
  const nonce = new Uint8Array(nonce_len);
  for (let i = 0; i < nonce_len; i++) {
    nonce[i] = 0;
  }
  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = 88;
  }

  const wasm_res = await benchWasmSalsa20(bytes, rounds, key, nonce, message).catch(err => console.log(err));
  const handwasm_res = await benchHandWasmSalsa20(true, bytes, rounds, key, nonce, message).catch(err => console.log(err));
  const handwasmpub_res = await benchHandWasmSalsa20(false, bytes, rounds, key, nonce, message).catch(err => console.log(err));
  const js_res = await benchJSSalsa20(bytes, rounds, key, nonce, message).catch(err => console.log(err));

  await promisify(fs.writeFile)('emcc.measurements', wasm_res.join('\n') + '\n');
  await promisify(fs.writeFile)('hand.measurements', handwasm_res.join('\n') + '\n');
  await promisify(fs.writeFile)('handpub.measurements', handwasmpub_res.join('\n') + '\n');
  await promisify(fs.writeFile)('js.measurements', js_res.join('\n') + '\n');
}

benchDriver().catch(err => console.log(err));
