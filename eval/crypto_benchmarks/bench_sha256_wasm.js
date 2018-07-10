const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/sha256/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchmarkDriver(is_sec) {
  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 10;

  let memory = new WebAssembly.Memory({ initial: 1, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance((is_sec ? "sec" : "strip") + "_sha256.wasm", { js: { memory } });
  let e = s.instance.exports;

  const karr_base = (is_sec ? 88 : 91);
  const hash_base = (is_sec ? 608 : 620);
  const hash_len = 32;
  const input_base = (is_sec ? 640 : 652);

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
  for (let i = 0; i < 64; i++) {
    mem[karr_base + i] = k[i];
  }


  let classes = new Array();
  for (let i = 0; i < number_measurements; i++) {
    classes.push(getRand(2));
  }

  let messages = new Array();
  for (let i = 0; i < number_measurements; i++) {
    messages.push(new Uint8Array(bytes));
    if (classes[i] == 0) {
      for (let j = 0; j < bytes; j++) {
        messages[i][j] = 0;
      }
    } else {
      for (let j = 0; j < bytes; j++) {
        messages[i][j] = getRand(0xff);;
      }
    }
  }

  let measurements = new Array();

  for (let i = 0; i < number_measurements; i++) {
    measurements.push(rdtscp());

    e.init();

    for (let j = 0; j < bytes; j++) {
      mem8[input_base + j] = messages[i][j];
    }

    for (let j = 0; j < rounds; j++) {
      e.update(bytes);
    }

    e.final();
  }
  measurements.push(rdtscp());

  fs.writeFile('params.log',
    [number_measurements].join('\n') + '\n',
    err => { if (err) throw err; });

  fs.writeFile('classes.log',
    classes.join('\n') + '\n',
    err => { if (err) throw err; });

  fs.writeFile('output.log',
    measurements.map(m => new int64(m[1], m[0]).toOctetString()).join('\n') + '\n',
    err => { if (err) throw err; });
}

const is_stripped = process.argv[2] == "--stripped";

benchmarkDriver(!is_stripped).catch(err => console.log(err));
