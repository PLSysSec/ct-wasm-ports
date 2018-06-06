const assert = require('assert');
const fs = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(fs.readFile);
const JSSalsa20 = require('js-salsa20');
const {
  performance,
  PerformanceObserver
} = require('perf_hooks');
const {instance} = require('./main.js');

class Salsa20Config {
  constructor(m) {
    this.module = m;
    this.exports = this.module.instance.exports;
    this.em = (rounds, bytes) => {
      this.exports.encrypt_many(rounds, bytes);
    }
  }
}

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function benchmarkDriver() {
  /* General vars */
  const key_len = 32;
  const nonce_len = 8;
  const bytes = 2048;
  const max = 255;
  
  /* Length of view into wasm memory for both plaintext and encrypted message */
  const length = Math.ceil(bytes / 4);
  
  /* Message range */
  const m_start = 16016; // change with available memory OR encrypt in place and disregard
  const m_end = m_start + length;

  /* Encrypted range */
  const c_start = 32;
  const c_end = c_start + length;

  let memory = new WebAssembly.Memory({ initial: 2 });
  //let memory = new WebAssembly.Memory({ initial: 2, secret: true });
  const mem_mod = await instance("mem.wasm", {js: {memory} }); 
 
  /* Initialize key, nonce, and message with random values */
  let key = new Uint8Array(key_len);
  for (let i = 0; i < key_len; i++) {
    key[i] = getRand(max);
  }
  let nonce = new Uint8Array(nonce_len);
  for (let i = 0; i < nonce_len; i++) {
    nonce[i] = getRand(max);
  }
  let message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = getRand(max);
  }

  if (bytes > 15984) {
    throw new Error('Current max number of bytes surpassed! Increase wasm memory.');
  }

  /* Instantiate and configure modules */
  const wasm_mod = await instance("pub_salsa20.wasm", {js: {memory} });
  const exp = wasm_mod.instance.exports;

  let init_mem = new Uint32Array(memory.buffer);

  /* FIXME div/4 may have some rounding issues for nont 4b-div bytes */

  /* Key setup */
  let _k = new Uint32Array(key_len/4);
  for (i = 0, j = 0; i < (key_len/4); i++, j += 4) {
  _k[i] = (key[j+3] << 24)
      | (key[j+2] << 16)
      | (key[j+1] << 8)
      | (key[j] << 0);
  }
  let k = new Uint32Array(_k);
  exp.keysetup(k[0], k[1], k[2], k[3], k[4], k[5], k[6], k[7]);

  /* Nonce setup */
  let _n = new Uint32Array(nonce_len/4);
  for (let i = 0, j = 0; i < (nonce_len/4); i++, j += 4) {
    _n[i] = (nonce[j+3] << 24)
        | (nonce[j+2] << 16)
        | (nonce[j+1] << 8)
        | (nonce[j] << 0);
  }
  let n = new Uint32Array(_n);
  exp.noncesetup(n[0], n[1]);

  /* Message setup */
  for (let i = m_start, j = 0; i < m_end; i++, j += 4) {
  init_mem[i] = (message[j+3] << 24) 
      | (message[j+2] << 16)
      | (message[j+1] << 8)
      | (message[j] << 0);
  }

  /* Configure objects */
  const wasm_obj = new Salsa20Config(wasm_mod);
  const js_obj = new JSSalsa20(key, nonce);

  /* Wrap to capture receiver */ 
  const wasm_em = wasm_obj.em.bind(wasm_mod);
  const js_encrypt = js_obj.encrypt.bind(js_obj);

  const rounds = 10000000;
  const warmup = 10000;

  const js_warmup = mes => {
    for (let i = 0; i < warmup; i++) {
      js_encrypt(mes);
    }
  };

  const js_actual = mes => {
    for (let i = 0; i < rounds; i++) {
      js_encrypt(mes);
    }
  };

  /* Wrap with timer */
  const wrapped_wasm_em = performance.timerify(wasm_obj.em);
  const wrapped_js_actual = performance.timerify(js_actual);

  const obs = new PerformanceObserver((list) => {
    fs.appendFile('./output8/' + bytes + 'b_' + rounds + 'r_wasm.data', 
        bytes + ' ' + (list.getEntries()[0].duration/rounds) + '\n', err => {
      if (err) throw err;
    });
  });
  obs.observe({ entryTypes: ['function'] });

  /* Benchmark */

  //js_warmup(message);
  //wrapped_js_actual(message);

  wrapped_wasm_em(rounds, bytes);

  /* Double check results */

  /*const w = init_mem.slice(c_start, c_end);

  const jsi = js_obj.encrypt(message);
  let jso = new Uint32Array(length);
  let end;
  if ((bytes % 4) == 0) end = bytes;
  else if ((bytes % 4) == 1) end = bytes + 3;
  else if ((bytes % 4) == 2) end = bytes + 2;
  else end = bytes + 1;
  for (let i = 0, j = 0; i < end; i++, j += 4) {
    jso[i] = (jsi[j+3] << 24)
        | (jsi[j+2] << 16)
	| (jsi[j+1] << 8)
	| (jsi[j] << 0);
  } 
  
  assert.deepEqual(w, jso);*/

  obs.disconnect();
}

benchmarkDriver().catch(err => console.log(err));
