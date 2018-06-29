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

  var global;
  const mem_base = 64 * 4;
  console.log("mem_base = " + mem_base);

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
        memoryBase: mem_base,
        tableBase: 0,
        abort,
	getTempRet0: function() {
	  return global;
	},
	_bitshift64Lshr: function(ls, ms, toshift) {
	  const ls_sh = ls >>> toshift; 
	  const ms_sh = ms << (32 - toshift);
	  // global value is ignored in module, can omit setting it?
	  global = ms >>> toshift;
	  return ms_sh | ls_sh;
	},
	_i64Add: function(ls1, ms1, ls2, ms2) {
	  const res = (ls1 + ls2) >>> 0;
	  if (res - ls1 != ls2) { // overflow
	    ms1 += 1;
	  }
	  if (ms2 != 0) {
	    ms1 += ms2;
	  }
	  global = ms1;
	  return res;
	},
        _memset: function(p, k, n) {
          for (let i = 0; i < n; i++) {
            mem[(p/4) + i] = k;
          }
        },
	_log: arg => console.log(arg)
      },
      global: { NaN, Infinity, },
    }
  );
  let e = s.instance.exports;

  const ctx_size = 112;
  const block_size = 32;

  /* ctx range */
  const ctx_start = mem_base + 64 * 8; 
  const ctx_end = ctx_start + ctx_size;
  console.log("ctx_start = " + ctx_start);

  /* message setup */
  const d_start = ctx_end;
  const d_end = d_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[d_start + i] = message[i];
  }
  console.log("d_start = " + d_start);

  /* hash range */
  const h_start = d_end;
  const h_end = h_start + block_size;
  console.log("h_start = " + h_start);
  console.log("h_end = " + h_end);

  e._sha256_init(ctx_start);

  console.log("...m...");
  console.log(mem8.slice(0, mem_base));
  console.log("...k...");
  console.log(mem8.slice(mem_base, ctx_start));
  console.log("...ctx...");
  console.log(mem8.slice(ctx_start, ctx_end - 56));
  console.log(mem8.slice(ctx_start + 56, ctx_end));
  console.log("...data...");
  console.log(mem8.slice(d_start, d_end));
  console.log("...hash...");
  console.log(mem8.slice(h_start, h_end));

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e._sha256_update(ctx_start, ctx_start, bytes);
    //e._sha256_transform(ctx_start, ctx_start);
  }
  e._sha256_final(ctx_start, h_start);
  measurements.push(rdtscp());

  console.log("...POST...");
  console.log("...m...");
  console.log(mem8.slice(0, mem_base));
  console.log("...k...");
  console.log(mem8.slice(mem_base, ctx_start));
  console.log("...ctx...");
  console.log(mem8.slice(ctx_start, ctx_end - 56));
  console.log(mem8.slice(ctx_start + 56, ctx_end));
  console.log("...data...");
  console.log(mem8.slice(d_start, d_end));
  console.log("...hash...");
  console.log(mem8.slice(h_start, h_end));

  console.log("emcc state = " + mem8.slice(ctx_end - 32, ctx_end));
  console.log("emcc hash  = " + mem8.slice(h_start, h_end));

  let preout = mem8.slice(h_start, h_end);

  let out = Array(32);
  let x;
  for (let i = 0; i < block_size; i++) {
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

async function benchHandWasmSha256(is_sec, bytes, rounds, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } 

  /* Compile and instantiate module */
  //let memory = new WebAssembly.Memory({ initial: 1, secret: is_sec });
  let s = await instance("../ct/" + (is_sec ? "" : "pub_") + "sha256.wasm", {});
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
  //let mem8 = new Uint8Array(memory.buffer);
  let mem = new Uint32Array(e.memory.buffer);
  let mem8 = new Uint8Array(e.memory.buffer);
  for (let i = 0; i < 64; i++) {
    mem[karr_base + i] = k[i];
  }

  for (let i = 0; i < bytes; i++) {
    mem8[input_base + i] = message[i];
  }

  e.init();

  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    e.update(bytes);
  }
  e.final();
  measurements.push(rdtscp());

  /*console.log("hand state = " + mem8.slice(0, 32));
  console.log("hand hash  = " + mem8.slice(hash_base, hash_base + hash_len));*/
  const preout = mem8.slice(hash_base, hash_base + hash_len);

  let out = Array(32);
  let x;
  for (let i = 0; i < hash_len; i++) {
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

async function benchJSSha256(bytes, rounds, message) {
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
  const bytes = 4096;
  const rounds = 10000;

  console.log("BYTES  = " + bytes);
  console.log("ROUNDS = " + rounds);

  const msg = "a";
  const buf = Buffer.from(msg);
  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = buf[0];
  }

  //const wasm_res = await benchWasmSha256(bytes, rounds, message).catch(err => console.log(err));
  const handwasm_res = await benchHandWasmSha256(true, bytes, rounds, message).catch(err => console.log(err));
  const handwasmpub_res = await benchHandWasmSha256(false, bytes, rounds, message).catch(err => console.log(err));
  const js_res = await benchJSSha256(bytes, rounds, message).catch(err => console.log(err));

  //await promisify(fs.writeFile)('emcc.measurements', wasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('hand.measurements', handwasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('handpub.measurements', handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('js.measurements', js_res[0].join('\n') + '\n');

  //assert.deepEqual(wasm_res[1], js_res[1]);
  assert.deepEqual(handwasm_res[1], js_res[1]);
  assert.deepEqual(handwasmpub_res[1], js_res[1]);
}

benchDriver().catch(err => console.log(err));
