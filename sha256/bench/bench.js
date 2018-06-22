const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const JSSha256 = require('sha.js');

function abort (what) {
  throw "abort: " + what;
}

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchWasmSha256(bytes, rounds, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } 

  /* Compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 256 });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let table = new WebAssembly.Table({ initial: 8, element: "anyfunc" });
  let s = await instance("../reference/sha256.O2.wasm",
    {
      env: {
        memory,
        table,
        memoryBase: 0,
        tableBase: 0,
        abort,
        _memset: function(p, k, n) {
          for (let i = 0; i < n; i++) {
            mem[(p/4) + i] = k;
          }
        }
      },
      global: { NaN, Infinity, },
    }
  );
  let e = s.instance.exports;

  const length = Math.ceil(bytes / 4);
  const ctx_size = 16;
  const key_size = 8;
  const iv_size = 2;

  /* ctx range */
  const ctx_start = 64;
  const ctx_end = ctx_start + ctx_size * 4;

  /* key setup */
  const k_start = ctx_end;
  const k_end = k_start + key_size * 4;
  const kbits = 256;
  for (let i = 0; i < key_size * 4; i++) {
    mem8[k_start + i] = key[i];
  }

  /* iv setup */
  const iv_start = k_end;
  const iv_end = iv_start + iv_size * 4;
  const ivbits = 64; // unused in implementation?
  for (let i = 0; i < iv_size * 4; i++) {
    mem8[iv_start + i] = nonce[i];
  }

  /* message setup */
  const m_start = iv_end;
  const m_end = m_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[m_start + i] = message[i];
  }

  /* ciphertext range */
  const c_start = m_end;
  const c_end = c_start + bytes;

  e._ECRYPT_keysetup(ctx_start, k_start, kbits, ivbits);
  e._ECRYPT_ivsetup(ctx_start, iv_start);

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e._ECRYPT_encrypt_bytes(ctx_start, m_start, c_start, bytes);
  }
  measurements.push(rdtscp());

  const output = mem8.slice(c_start, c_end);

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchHandWasmSha256(bytes, rounds, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } 

  /* Compile and instantiate module */
  //let memory = new WebAssembly.Memory({ initial: 1, secret: true });
  let s = await instance("../ct/sha256.wasm", {});
  //let s = await instance("../ct/sha256.wasm", { js: { memory } });
  let e = s.instance.exports;

  const karr_base = 88;
  const hash_base = 608;
  const hash_len = 32;
  const input_base = 640;

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
  //let mem = new Int32Array(memory.buffer);
  //let memb = new Uint8Array(memory.buffer);
  let mem = new Uint32Array(e.memory.buffer);
  let memb = new Uint8Array(e.memory.buffer);
  for (let i = 0; i < 64; i++) {
    mem[karr_base + i] = k[i];
  }

  //e.init();

  for (let i = 0; i < bytes; i++) {
    memb[input_base + i] = message[i];
  }

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.init();
    e.update(bytes);
  }
  e.final();
  measurements.push(rdtscp());

  const preout = memb.slice(hash_base, hash_base + hash_len);

  let out = Array(32);
  let x;
  for (let i = 0; i < 32; i++) {
    x = preout[i].toString(16);
    if (x == 0) out[i] = "00";
    else if (x == 1) out[i] = "01";
    else if (x == 2) out[i] = "02";
    else if (x == 3) out[i] = "03";
    else if (x == 4) out[i] = "04";
    else if (x == 5) out[i] = "05";
    else if (x == 6) out[i] = "06";
    else if (x == 7) out[i] = "07";
    else if (x == 8) out[i] = "08";
    else if (x == 9) out[i] = "09";
    else if (x == "a") out[i] = "0a";
    else if (x == "b") out[i] = "0b";
    else if (x == "c") out[i] = "0c";
    else if (x == "d") out[i] = "0d";
    else if (x == "e") out[i] = "0e";
    else if (x == "f") out[i] = "0f";
    else out[i] = x;
  }

  const output = out.join("");

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchJSSha256(bytes, rounds, message) { // TODO
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  const warmup = 10000;

  /* Setup and run */
  const ew = new JSSha256.sha256();

  /* Warmup */
  for (let i = 0; i < warmup; i++) {
    ew.update(message);
  }

  /* Setup and run */
  const e = new JSSha256.sha256();

  var output;
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    output = e.update(message);
  }
  measurements.push(rdtscp());

  output = output.digest('hex');

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const bytes = 64;
  const rounds = 1;

  const msg = "a";
  const buf = Buffer.from(msg);
  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = buf[0];
  }

  //const wasm_res = await benchWasmSha256(bytes, rounds, message).catch(err => console.log(err));
  const handwasm_res = await benchHandWasmSha256(bytes, rounds, message).catch(err => console.log(err));
  //const handwasmpub_res = await benchHandWasmSha256(bytes, rounds, message).catch(err => console.log(err));
  const js_res = await benchJSSha256(bytes, rounds, message).catch(err => console.log(err));

  //await promisify(fs.writeFile)('emcc.measurements', wasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('hand.measurements', handwasm_res[0].join('\n') + '\n');
  //await promisify(fs.writeFile)('handpub.measurements', handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('js.measurements', js_res[0].join('\n') + '\n');

  //assert.deepEqual(handwasm_res[1], new Uint8Array([
    /*176,131,151,154,4,162,228,89,239,85,34,39,173,152,47,200,
    213,33,119,126,67,239,238,63,114,98,116,227,151,69,230,135]));*/ // 64 bytes (works for all rounds)
    /*26,255,215,71,142,163,58,177,6,228,156,243,154,19,175,8,
    164,146,134,190,221,52,0,183,149,178,87,217,143,80,58,85]));*/ // 4096 bytes (1 round)
    /*49,226,13,45,237,60,112,46,74,42,192,78,222,50,42,232,56,
    43,52,42,103,161,78,7,154,241,8,185,32,96,71,148]));*/ // 4096 bytes (10000 rounds)
  //assert.deepEqual(wasm_res[1], js_res[1]);
  //assert.deepEqual(handwasmpub_res[1], js_res[1]);
  assert.deepEqual(handwasm_res[1], js_res[1]);
}

benchDriver().catch(err => console.log(err));
