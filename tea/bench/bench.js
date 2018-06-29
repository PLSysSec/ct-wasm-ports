const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const int64 = require('node-int64');
const readFileAsync = promisify(fs.readFile);
const wasm = require('../tea_wasm.js');
const js = require('../tea_js.js');

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

async function benchWasmTea(bytes, rounds, key, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } else if (bytes > 15984) {
    throw new Error('Current max number of bytes surpassed! Current behavior is undefined. Increase wasm memory.');
  }

  /* Compile and instantiate module */
  let memory = new WebAssembly.Memory({ initial: 256 });
  let mem = new Uint32Array(memory.buffer);
  let mem8 = new Uint8Array(memory.buffer);
  let table = new WebAssembly.Table({ initial: 8, element: "anyfunc" });
  let s = await instance("../tea.O2.wasm",
    {
      env: {
        table,
        memory,
        memoryBase: 0,
        tableBase: 0,
        abort,
        _printf: function(p, n) {
          for (let i = 0; i < n; i++) {
            mem[(p/4) + i] = n;
          }
        }
      },
      global: { NaN, Infinity, },
    }
  );
  let e = s.instance.exports;

  /* ciphertext range */
  const m_start = 0;
  const k_start = 8; // TODO why does this work...

  // message
  mem[0] = message[0];
  mem[1] = message[1];
  // key
  mem[2] = key[0];
  mem[3] = key[1];
  mem[4] = key[2];
  mem[5] = key[3];

  let measurements = new Array();

  /* Run */
  for (let i = 0; i < rounds; i++) {
//    mem[0] = message[0];
//    mem[1] = message[1];
    measurements.push(rdtscp());
    e._tea_encrypt(m_start, k_start);
  }
  measurements.push(rdtscp());

  const output = [mem[0], mem[1]];

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchHandWasmTea(is_sec, bytes, rounds, key, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  } else if (bytes > 15984) {
    throw new Error('Current max number of bytes surpassed! Current behavior is undefined. Increase wasm memory.');
  }

  const memory = new WebAssembly.Memory({initial: 1, secret: is_sec});
  const tea = await instance("../" + (is_sec ? "sec_" : "") + "ref.wasm", {js: {memory}});
  const mem = new Uint32Array(memory.buffer);

  // message
  mem[0] = message[0];
  mem[1] = message[1];
  // key
  mem[2] = key[0];
  mem[3] = key[1];
  mem[4] = key[2];
  mem[5] = key[3];

  let measurements = new Array();

  /* Run */
  for (let i = 0; i < rounds; i++) {
//    mem[0] = message[0];
//    mem[1] = message[1];
    measurements.push(rdtscp());
    tea.instance.exports.encrypt();
  }
  measurements.push(rdtscp());

  const output = [mem[0], mem[1]];

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchJSTea(bytes, rounds, key, message) {
  if (bytes < 0) {
    throw new Error('Number of bytes should be non-negative!');
  }

  var output;
  let measurements = new Array();

  js.init(() => {
    const warmup = 10000;

    /* Warmup */
    for (let i = 0; i < warmup; i++) {
      js.encrypt(message, key);
    }

    /* Run */
    for (let i = 0; i < rounds; i++) {
      measurements.push(rdtscp());
      output = js.encrypt(message, key);
    }
    measurements.push(rdtscp());
  });

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const key_len = 16;
  const bytes = 8;
  const rounds = 1000;

  console.log("BYTES  = " + bytes);
  console.log("ROUNDS = " + rounds);

  const message = new Uint32Array([ 0xdeadbeef, 0xbeeff00d ]);
  const key     = new Uint32Array([ 0xd34db33f, 0xb33ff33d, 0xf000ba12, 0xdeadf00d]);

  //const wasm_res = await benchWasmTea(bytes, rounds, key, message).catch(err => console.log(err));
  const handwasmpub_res = await benchHandWasmTea(false, bytes, rounds, key, message).catch(err => console.log(err));
  const handwasm_res = await benchHandWasmTea(true, bytes, rounds, key, message).catch(err => console.log(err));
  const js_res = await benchJSTea(bytes, rounds, key, message).catch(err => console.log(err));

  //await promisify(fs.writeFile)('emcc.measurements', wasm_res[0].join('\n') + '\n');
  /*await promisify(fs.writeFile)('hand.measurements', handwasm_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('handpub.measurements', handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)('js.measurements', js_res[0].join('\n') + '\n');*/
  await promisify(fs.appendFile)('hand.measurements', handwasm_res[0].join('\n') + '\n');
  await promisify(fs.appendFile)('handpub.measurements', handwasmpub_res[0].join('\n') + '\n');
  await promisify(fs.appendFile)('js.measurements', js_res[0].join('\n') + '\n');

  //assert.deepEqual(wasm_res[1], js_res[1]);
  assert.deepEqual(handwasm_res[1], js_res[1]);
  assert.deepEqual(handwasmpub_res[1], js_res[1]);
}

benchDriver().catch(err => console.log(err));
