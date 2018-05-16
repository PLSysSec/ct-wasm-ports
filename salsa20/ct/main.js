const assert = require('assert');
const {readFile} = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(readFile);

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testSalsa20() {
  /* Compile and instantiate module */
  let s = await instance("sec_salsa20.wasm", {});
  let e = s.instance.exports;

  /* Load arguments */
  let sec_mem = new Int32Array(e.memory.buffer);
  for (let i = 0; i < 16; i++) {
    sec_mem[i] = 8888;
  }

  /* Run salsa20 */
  e.ECRYPT_keystream_bytes(64);

  /* Check the output */
  assert.deepEqual(sec_mem.slice(16, 32), new Int32Array([2050581199, 2146000113,
      -882836924, 2029613081, 2029613081, 2050581199, 2146000113, -882836924,
      -882836924, 2029613081, 2050581199, 2146000113, 2146000113, -882836924,
      2029613081, 2050581199]));
}

testSalsa20().catch(err => console.log(err));
