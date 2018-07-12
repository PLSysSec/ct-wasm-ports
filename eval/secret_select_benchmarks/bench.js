const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');
const rounds = process.argv[2];
const v8modFile = process.argv[3];
const polyfillFile = process.argv[4];
const outdir = process.argv[5];

async function instance(fname, i) {
  let f = await readFileAsync(fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchV8Mod() {
  let s = await instance(v8modFile);
  let e = s.instance.exports;

  let output;
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    output = e.secret_select(3, 7, 0);
  }
  measurements.push(rdtscp());

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchPolyfill() {
  let s = await instance(polyfillFile);
  let e = s.instance.exports;

  let output;
  let measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    measurements.push(rdtscp());
    output = e.secret_select(3, 7, 0);
  }
  measurements.push(rdtscp());

  return [measurements.map(x => new int64(x[1], x[0]).toOctetString()), output];
}

async function benchDriver() {
  const v8mod_res = await benchV8Mod();
  const polyfill_res = await benchPolyfill();

  await promisify(fs.writeFile)(`${outdir}/v8mod.measurements`, v8mod_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/polyfill.measurements`, polyfill_res[0].join('\n') + '\n');

  assert.deepEqual(v8mod_res[1], polyfill_res[1]);
}

benchDriver().catch(err => console.log(err));
