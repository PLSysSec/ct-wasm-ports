const assert = require('assert');
const wasm = require('./tea_wasm.js');
const js   = require('./tea_js.js');

const message = new Uint32Array([ 0xdeadbeef, 0xbeeff00d ]);
const key     = new Uint32Array([ 0xd34db33f, 0xb33ff33d, 0xf000ba12, 0xdeadf00d]);

wasm.init(() => {
  console.log('.... wasm ....');
  console.log(message);
  const ciphertext = wasm.encrypt(message, key);
  console.log(ciphertext);
  const plaintext  = wasm.decrypt(ciphertext, key);
  console.log(plaintext);
  assert(plaintext[0] == message[0] && plaintext[1] == message[1]);

  js.init(() => {
    console.log('.... javascript ....');
    console.log(message);
    const ciphertext = js.encrypt(message, key);
    console.log(ciphertext);
    const plaintext  = js.decrypt(ciphertext, key);
    console.log(plaintext);
    assert(plaintext[0] == message[0] && plaintext[1] == message[1]);
  });
});
