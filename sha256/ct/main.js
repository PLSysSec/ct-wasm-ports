const assert = require('assert');
const {readFile} = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(readFile);
const shajs = require('sha.js');

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

const karr_base = 88;
const hash_base = 608;
const hash_len = 32;
const input_base = 640;

function testcase (msg, memb, sha256) {
  sha256.init();
  console.log(`testing length ${msg.length} message: ${msg}`);
  buf = Buffer.from(msg);
  for (let i = 0; i < buf.length; i++) {
    memb[input_base + i] = buf[i];
  }
  sha256.update(buf.length);
  sha256.final();
  assert.deepEqual(memb.slice(hash_base, hash_base + hash_len), shajs('sha256').update(buf).digest());
  console.log('  SUCCESS!');
}

async function testSha256() {
  /* Compile and instantiate module */
  const s = await instance("sha256.wasm", {});
  const sha256 = s.instance.exports;

  /* load k array */
  const k = [
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
  ];
  let mem = new Int32Array(sha256.memory.buffer);
  let memb = new Uint8Array(sha256.memory.buffer);
  for (let i = 0; i < 64; i++) {
    mem[karr_base + i] = k[i];
  }

  /* test initialization */
  sha256.init();
  assert.deepEqual(mem.slice(0, 8), new Int32Array([
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19
  ]));

  testcase("", memb, sha256);
  testcase("a", memb, sha256);
  testcase("abc", memb, sha256);
  testcase("a", memb, sha256);
  testcase("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", memb, sha256);
  testcase("aaaaaaaaaa", memb, sha256);
  testcase("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcde", memb, sha256);

  let bigmsg = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
  let limit = 200;
  for (let j = 64; j < Math.min(bigmsg.length + 1, limit); j++) {
    testcase(bigmsg.substr(0, j), memb, sha256);
  }

  testcase("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdec", memb, sha256);
  testcase("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", memb, sha256);
}

testSha256().catch(err => console.log(err));
