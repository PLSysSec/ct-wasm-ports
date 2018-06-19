const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSSalsa20 = require('js-salsa20');

function abort (what) {
  throw "abort: " + what;
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testWasmSalsa20(bytes, key, nonce, message) {
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
  let s = await instance("salsa20.O2.wasm",
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

  e._ECRYPT_encrypt_bytes(ctx_start, m_start, c_start, bytes);

  /* Encrypted array */
  const output = mem.slice(c_start/4, c_end/4);

  return output;
}

async function testJSSalsa20(bytes, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const length = Math.ceil(bytes / 4);

  /* Setup and run */
  const encrypt = new JSSalsa20(key, nonce).encrypt(message);

  /* Reformat output */
  let output = new Uint32Array(length);
  let end;
  if ((bytes % 4) == 0) end = bytes;
  else if ((bytes % 4) == 1) end = bytes + 3;
  else if ((bytes % 4) == 2) end = bytes + 2;
  else end = bytes + 1;
  for (let i = 0, j = 0; i < end; i++, j += 4) {
    output[i] = (encrypt[j+3] << 24)
        | (encrypt[j+2] << 16)
        | (encrypt[j+1] << 8)
        | (encrypt[j] << 0);
  }

  return output;
}

async function testDriver() {
  const key_len = 32;
  const nonce_len = 8;
  const bytes = 15984;

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

  const wasm_res = await testWasmSalsa20(bytes, key, nonce, message).catch(err => console.log(err));
  const js_res = await testJSSalsa20(bytes, key, nonce, message).catch(err => console.log(err));

  assert.deepEqual(wasm_res, js_res);
  console.log('all good');
}

testDriver().catch(err => console.log(err));
