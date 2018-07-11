const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');
const JSSalsa20 = require('js-salsa20');

function getRand(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/../crypto_benchmarks/salsa20/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchmarkDriver(is_sec) {
  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 10;

  const length = Math.ceil(bytes / 4);
  const key_size = 8;
  const iv_size = 2;

  const nonce = new Uint32Array(iv_size);
  for (let i = 0; i < iv_size; i++) {
    nonce[i] = 0;
  }

  const message = new Uint8Array(bytes);
  for (let i = 0; i < bytes; i++) {
    message[i] = 0;
  }

  let memory = new WebAssembly.Memory({ initial: 2, secret: is_sec });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let s = await instance((is_sec ? "sec" : "strip") + "_salsa20.wasm", { js: { memory } });
  let e = s.instance.exports;

  /* ciphertext range */
  const c_start = 32 * 4;
  const c_end = c_start + bytes;

  /* message range */
  const m_start = c_end;
  const m_end = m_start + bytes;
  for (let i = 0; i < bytes; i++) {
    mem8[m_start + i] = message[i];
  }


  let classes = new Array();
  for (let i = 0; i < number_measurements; i++) {
    classes.push(getRand(2));
  }

  let keys = new Array();
  for (let i = 0; i < number_measurements; i++) {
    keys.push(new Uint32Array(key_size));
    if (classes[i] == 0) {
      for (let j = 0; j < key_size; j++) {
        keys[i][j] = 0;
      }
    } else {
      for (let j = 0; j < key_size; j++) {
        keys[i][j] = getRand(0xffffffff);
      }
    }
  }

  let measurements = new Array();

  for (let i = 0; i < number_measurements; i++) {
    measurements.push(rdtscp());

    /*
    e.keysetup(
      keys[i][0],
      keys[i][1],
      keys[i][2],
      keys[i][3],
      keys[i][4],
      keys[i][5],
      keys[i][6],
      keys[i][7]);
    e.noncesetup(nonce[0], nonce[1]);
    */
    mem[ 0] = 0x61707865;
    mem[ 4] = keys[i][0];
    mem[ 8] = keys[i][1];
    mem[12] = keys[i][2];
    mem[16] = keys[i][3];
    mem[20] = 0x3320646e;
    mem[24] = nonce[0];
    mem[28] = nonce[1];
    mem[32] = 0;
    mem[36] = 0;
    mem[40] = 0x79622d32;
    mem[44] = keys[i][4];
    mem[48] = keys[i][5];
    mem[52] = keys[i][6];
    mem[56] = keys[i][7];
    mem[60] = 0x6b206574;

    for (let i = 0; i < rounds; i++) {
      e.encrypt(bytes);
    }
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
