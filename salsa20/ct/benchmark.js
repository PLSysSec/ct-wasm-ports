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
  constructor(m, k, n) {
    this.module = m;
    this.exports = this.module.instance.exports;
    this.key = k;
    this.nonce = n;
    this.encrypt = (message) => {
      const bytes = message.length;
      const length = Math.ceil(bytes / 4);
      const key_size = 8;
      const nonce_size = 2;

      /* Message range */
      const m_start = 16016;
      const m_end = m_start + length;

      /* Encrypted range */
      const c_start = 32;
      const c_end = c_start + length;

      let i = 0;
      let j = 0;
      /* Key setup */
      let k = new Uint32Array(key_size);
      for (i = 0, j = 0; i < key_size; i++, j += 4) {
        k[i] = (this.key[j+3] << 24)
            | (this.key[j+2] << 16)
            | (this.key[j+1] << 8)
            | (this.key[j] << 0);
      }
      this.exports.keysetup(k[0], k[1], k[2], k[3], k[4], k[5], k[6], k[7]);

      /* Nonce setup */
      let n = new Uint32Array(nonce_size);
      for (let i = 0, j = 0; i < nonce_size; i++, j += 4) {
        n[i] = (this.nonce[j+3] << 24)
            | (this.nonce[j+2] << 16)
            | (this.nonce[j+1] << 8)
            | (this.nonce[j] << 0);
      }
      this.exports.noncesetup(n[0], n[1]);

      /* Message setup */
      let mem = new Uint32Array(this.exports.memory.buffer);
      for (let i = m_start, j = 0; i < m_end; i++, j += 4) {
        mem[i] = (message[j+3] << 24) 
            | (message[j+2] << 16)
            | (message[j+1] << 8)
            | (message[j] << 0);
      }

      /* Run salsa20 */
      this.exports.encrypt(bytes);

      /* Encrypted array */
      const output = mem.slice(c_start, c_end);

      return output;
    }
    this.encrypt_many = (message, rounds) => {
      const bytes = message.length;
      const length = Math.ceil(bytes / 4);
      const key_size = 8;
      const nonce_size = 2;

      /* Message range */
      const m_start = 16016;
      const m_end = m_start + length;

      /* Encrypted range */
      const c_start = 32;
      const c_end = c_start + length;

      let i = 0;
      let j = 0;
      /* Key setup */
      let k = new Uint32Array(key_size);
      for (i = 0, j = 0; i < key_size; i++, j += 4) {
        k[i] = (this.key[j+3] << 24)
            | (this.key[j+2] << 16)
            | (this.key[j+1] << 8)
            | (this.key[j] << 0);
      }
      this.exports.keysetup(k[0], k[1], k[2], k[3], k[4], k[5], k[6], k[7]);

      /* Nonce setup */
      let n = new Uint32Array(nonce_size);
      for (let i = 0, j = 0; i < nonce_size; i++, j += 4) {
        n[i] = (this.nonce[j+3] << 24)
            | (this.nonce[j+2] << 16)
            | (this.nonce[j+1] << 8)
            | (this.nonce[j] << 0);
      }
      this.exports.noncesetup(n[0], n[1]);

      /* Message setup */
      let mem = new Uint32Array(this.exports.memory.buffer);
      for (let i = m_start, j = 0; i < m_end; i++, j += 4) {
        mem[i] = (message[j+3] << 24) 
            | (message[j+2] << 16)
            | (message[j+1] << 8)
            | (message[j] << 0);
      }

      /* Run salsa20 */
      this.exports.encrypt_many(rounds, bytes);

      /* Encrypted array */
      const output = mem.slice(c_start, c_end);

      return output;
    }
  }
}

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function benchmarkDriver() {
  const key_len = 32;
  const nonce_len = 8;
  const bytes = 8192; //TODO 8192 for bind_js still
  const max = 255;
 
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
  const wasm_mod = await instance("sec_salsa20.wasm", {});
  const wasm_obj = new Salsa20Config(wasm_mod, key, nonce);
  const js_obj = new JSSalsa20(key, nonce);

  /* Wrap to capture receiver */ 
  //const wasm_encrypt = (mes => wasm_obj.encrypt(mes));
  //const js_encrypt = (mes => js_obj.encrypt(mes));
  const wasm_encrypt = wasm_obj.encrypt.bind(wasm_mod);
  const wasm_encrypt_many = wasm_obj.encrypt_many.bind(wasm_mod);
  const js_encrypt = js_obj.encrypt.bind(js_obj);

  const rounds = 10000000;
  const warmup = 10000;

  const wasm_actual = mes => {
    (() => {
      for (let i = 0; i < rounds; i++) {
        wasm_encrypt(mes);
      }
    })();
  };

  const wasm_many = mes => {
    (() => {
      wasm_encrypt_many(mes, rounds);
    })();
  };

  const js_warmup = mes => {
    (() => {
      for (let i = 0; i < warmup; i++) {
        js_encrypt(mes);
      }
    })();
  };

  const js_actual = mes => {
    (() => {
      for (let i = 0; i < rounds; i++) {
        js_encrypt(mes);
      }
    })();
  };

  /* Wrap with timer */
  const wrapped_wasm_actual = performance.timerify(wasm_actual);
  const wrapped_wasm_many = performance.timerify(wasm_many);
  const wrapped_js_actual = performance.timerify(js_actual);

  /* File name: w_x_y_z.data
     w: number of bytes
     x: number of rounds
     y: wrapped or bind used
     z: js crossover or not
  */
  const obs = new PerformanceObserver((list) => {
    fs.appendFile('./output/' + bytes + 'b_' + rounds + 'r_bind_js.data', 
        (list.getEntries()[0].duration/rounds) + '\n', err => {
      if (err) throw err;
    });
  });
  obs.observe({ entryTypes: ['function'] });

  /* Benchmark */
  wrapped_wasm_actual(message);
  //wrapped_wasm_many(message);
  js_warmup(message);
  wrapped_js_actual(message);

  obs.disconnect();
}

benchmarkDriver().catch(err => console.log(err));
