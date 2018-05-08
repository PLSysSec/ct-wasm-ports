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
  let p = await instance("pub_salsa20.wasm", { sec: s.instance.exports });
  let e = p.instance.exports;

  e.salsa20();

  assert(e.read(64) === 2050581199, 'encryption mismatch');
  assert(e.read(68) === 2146000113, 'encryption mismatch');
  //assert(e.read(72) === 3412130372, 'encryption mismatch');
  assert(e.read(72) === -882836924, 'encryption mismatch');
  assert(e.read(76) === 2029613081, 'encryption mismatch');
  assert(e.read(80) === 2029613081, 'encryption mismatch');
  assert(e.read(84) === 2050581199, 'encryption mismatch');
  assert(e.read(88) === 2146000113, 'encryption mismatch');
  //assert(e.read(92) === 3412130372, 'encryption mismatch');
  assert(e.read(92) === -882836924, 'encryption mismatch');
  //assert(e.read(96) === 3412130372, 'encryption mismatch');
  assert(e.read(96) === -882836924, 'encryption mismatch');
  assert(e.read(100) === 2029613081, 'encryption mismatch');
  assert(e.read(104) === 2050581199, 'encryption mismatch');
  assert(e.read(108) === 2146000113, 'encryption mismatch');
  assert(e.read(112) === 2146000113, 'encryption mismatch');
  //assert(e.read(116) === 3412130372, 'encryption mismatch');
  assert(e.read(116) === -882836924, 'encryption mismatch');
  assert(e.read(120) === 2029613081, 'encryption mismatch');
  assert(e.read(124) === 2050581199, 'encryption mismatch');
}

testSalsa20().catch(err => console.log(err));
