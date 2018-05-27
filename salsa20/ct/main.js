const assert = require('assert');
const fs = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(fs.readFile);
const JSSalsa20 = require('js-salsa20');

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
  let s = await instance("sec_salsa20.wasm", {});
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);
  const key_size = 8;
  const nonce_size = 2;

  /* Message range */
  const m_start = 16016;
  const m_end = m_start + length;

  /* Encrypted range */
  const c_start = 32;
  const c_end = c_start + length;

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
  let n = new Uint32Array(nonce_size);
  for (let i = 0, j = 0; i < nonce_size; i++, j += 4) {
    n[i] = (nonce[j+3] << 24)
        | (nonce[j+2] << 16)
	| (nonce[j+1] << 8)
	| (nonce[j] << 0);
  }
  e.noncesetup(n[0], n[1]);

  /* Message setup */
  let sec_mem = new Uint32Array(e.memory.buffer);
  for (let i = m_start, j = 0; i < m_end; i++, j += 4) {
    sec_mem[i] = (message[j+3] << 24) 
        | (message[j+2] << 16)
	| (message[j+1] << 8)
	| (message[j] << 0);
  }

  /* Run salsa20 */
  e.encrypt(bytes);

  /* Encrypted array */
  const output = sec_mem.slice(c_start, c_end);

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
}

testDriver().catch(err => console.log(err));

module.exports = {
  instance
};
