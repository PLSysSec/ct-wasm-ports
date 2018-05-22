const assert = require('assert');
const {readFile} = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(readFile);
const jssalsa20 = require('js-salsa20');

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testWasmSalsa20(bytes, key, nonce, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } else if (bytes > 2032) {
    throw new Error('Current max number of bytes surpassed! Increase wasm memory.');
  }

  /* Compile and instantiate module */
  let s = await instance("sec_salsa20.wasm", {});
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);

  /* Message range */
  const m_start = 4096;
  const m_end = m_start + length;

  /* Encrypted range */
  const c_start = 32;
  const c_end = c_start + length;

  /* Load/format input */
  let sec_mem = new Uint32Array(e.memory.buffer);
  for (let i = m_start, m = 0; i < m_end; i++, m += 4) {
    sec_mem[i] = (message[m+3] << 24) 
        | (message[m+2] << 16)
	| (message[m+1] << 8)
	| (message[m] << 0);
  }

  /* Key setup */
  e.ECRYPT_keysetup();

  /* Nonce setup */
  e.ECRYPT_ivsetup();

  /* Run salsa20 */
  e.ECRYPT_encrypt_bytes(bytes);

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
  const encrypt = new jssalsa20(key, nonce).encrypt(message);

  /* Reformat output */
  let output = new Uint32Array(length);
  let end;
  if ((bytes % 4) == 0) end = bytes;
  else if ((bytes % 4) == 1) end = bytes + 3;
  else if ((bytes % 4) == 2) end = bytes + 2;
  else end = bytes + 1;
  for (let i = 0; i < end; i += 4) {
    let index = (i / 4);
    output[index] = (encrypt[i+3] << 24)
        | (encrypt[i+2] << 16)
	| (encrypt[i+1] << 8)
	| (encrypt[i] << 0);
  } 
  
  return output;
}

async function testDriver() {
  const bytes = 64;
  const key = new Uint8Array([0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0]);
  const nonce = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0]);
  const message = new Uint8Array([88, 17, 28, 88, 
    88, 88, 88, 88, 
    88, 88, 88, 88, 
    88, 26, 88, 88, 
    84, 88, 80, 28, 
    38, 88, 88, 88, 
    88, 88, 45, 88, 
    88, 08, 88, 89, 
    88, 88, 88, 88, 
    88, 78, 91, 88, 
    88, 88, 88, 88, 
    88, 88, 88, 88, 
    88, 88, 88, 88, 
    86, 88, 85, 88, 
    88, 48, 08, 88, 
    88, 88, 88, 88]);

  const wasm_res = await testWasmSalsa20(bytes, key, nonce, message).catch(err => console.log(err));
  const js_res = await testJSSalsa20(bytes, key, nonce, message).catch(err => console.log(err));

  //console.log(wasm_res);
  //console.log(js_res);

  assert.deepEqual(wasm_res, js_res);
}

testDriver().catch(err => console.log(err));
