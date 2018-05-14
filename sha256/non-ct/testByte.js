const assert = require('assert');
const {readFile} = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(readFile);

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testSha256() {
  /* Compile and instantiate module */
  const s = await instance("byte.wasm", {});
  const sha256 = s.instance.exports;

  let mem = new Int32Array(sha256.memory.buffer);
  mem[0] = 0xaabbccdd;

  assert.equal(sha256.readByte(0), 0x000000dd);
  assert.equal(sha256.readByte(1), 0x000000cc);
  assert.equal(sha256.readByte(2), 0x000000bb);
  assert.equal(sha256.readByte(3), 0x000000aa);

  sha256.writeByte(0, 0x11);
  assert.equal(sha256.readByte(0), 0x11);
  sha256.writeByte(1, 0x22);
  assert.equal(sha256.readByte(1), 0x22);
  assert.equal(sha256.readByte(0), 0x11);
  sha256.writeByte(2, 0x33);
  assert.equal(sha256.readByte(2), 0x33);
  assert.equal(sha256.readByte(1), 0x22);
  assert.equal(sha256.readByte(0), 0x11);
  sha256.writeByte(3, 0x44);
  assert.equal(sha256.readByte(3), 0x44);
  assert.equal(sha256.readByte(2), 0x33);
  assert.equal(sha256.readByte(1), 0x22);
  assert.equal(sha256.readByte(0), 0x11);
  
  sha256.writeByte(0, 0xffffffaa);
  assert.equal(sha256.readByte(0), 0xaa);
  assert.equal(sha256.readByte(1), 0x22);
  assert.equal(sha256.readByte(2), 0x33);
  assert.equal(sha256.readByte(3), 0x44);
}

testSha256().catch(err => console.log(err));
