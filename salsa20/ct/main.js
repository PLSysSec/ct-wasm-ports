const assert = require('assert');
const {readFile} = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(readFile);
const jssalsa = require('js-salsa20');

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testSalsa20() {
  /* JS instantiation */
  /*const key = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, ]);
  const nonce = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0]);
  const message = new Uint8Array([0, 0, 34, 184, 
      0, 0, 34, 184,
      0, 0, 34, 184, 
      0, 0, 34, 184,
      0, 0, 34, 184,
      0, 0, 34, 184,
      0, 0, 34, 184,
      0, 0, 34, 184, 
      0, 0, 34, 184,
      0, 0, 34, 184,
      0, 0, 34, 184, 
      0, 0, 34, 184,
      0, 0, 34, 184,
      0, 0, 34, 184, 
      0, 0, 34, 184,
      0, 0, 34, 184]);

  const encrypt = new jssalsa(key, nonce).encrypt(message);*/

  /* ct-wasm instantiation */
  let s = await instance("sec_salsa20.wasm", {});
  let e = s.instance.exports;

  for (let i = 0; i < 64; i += 4) {
    e.write_sec(i, 184);
    e.write_sec(i + 1, 34);
    e.write_sec(i + 2, 0);
    e.write_sec(i + 3, 0);
  }

  e.ss20();

  let output_check = new Int32Array(e.memory.buffer.slice(64, 128));
  assert.deepEqual(output_check, new Int32Array([2050581199, 2146000113, 
      -882836924, 2029613081, 2029613081, 2050581199, 2146000113, -882836924, 
      -882836924, 2029613081, 2050581199, 2146000113, 2146000113, -882836924, 
      2029613081, 2050581199]));
}

testSalsa20().catch(err => console.log(err));
