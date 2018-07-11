const assert = require('assert');
const fs = require('fs');
const {promisify, rdtscp} = require('util');
const readFileAsync = promisify(fs.readFile);
const int64 = require('node-int64');
const rounds = process.argv[2];
const localFile = process.argv[3];
const remoteFile = process.argv[4];
const outdir = process.argv[5];

const maxInt4byte = 4294967295;
//const maxInt8byte = 18446744073709551615;

async function instance(fname, i) {
  let f = await readFileAsync(fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchLocal() {
  let memory = new WebAssembly.Memory({initial: 1});
  let mem = new Uint32Array(memory.buffer);
  let s = await instance(localFile, {js: {memory}});
  let e = s.instance.exports;

  // load32
  let ld32measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    ld32measurements.push(rdtscp());
    e.load32(0);
  }
  ld32measurements.push(rdtscp());

  // load64
  let ld64measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    ld64measurements.push(rdtscp());
    e.load64(0);
  }
  ld64measurements.push(rdtscp());

  // store32
  let st32measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    st32measurements.push(rdtscp());
    e.store32(0, maxInt4byte);
  }
  st32measurements.push(rdtscp());

  // store64
  let st64measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    st64measurements.push(rdtscp());
    e.store64(0);//, maxInt8byte);
  }
  st64measurements.push(rdtscp());

  return [
    ld32measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    ld64measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    st32measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    st64measurements.map(x => new int64(x[1], x[0]).toOctetString())
  ];
}

async function benchRemote() {
  let memory = new WebAssembly.Memory({initial: 1});
  let mem = new Uint32Array(memory.buffer);
  let r = await instance(localFile, {js: {memory}});
  let x = r.instance.exports;
  let s = await instance(remoteFile, 
    { 
      js : {memory},
      funcs : {
        load32 : x.load32,
        load64 : x.load64,
        store32 : x.store32,
        store64 : x.store64
      }
    }
  );
  let e = s.instance.exports;

  // load32
  let ld32measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    ld32measurements.push(rdtscp());
    e.load32(0);
  }
  ld32measurements.push(rdtscp());

  // load64
  let ld64measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    ld64measurements.push(rdtscp());
    e.load64(0);
  }
  ld64measurements.push(rdtscp());

  // store32
  let st32measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    st32measurements.push(rdtscp());
    e.store32(0, maxInt4byte);
  }
  st32measurements.push(rdtscp());

  // store64
  let st64measurements = new Array();
  for (let i = 0; i < rounds; i++) {
    st64measurements.push(rdtscp());
    e.store64(0);//, maxInt8byte);
  }
  st64measurements.push(rdtscp());

  return [
    ld32measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    ld64measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    st32measurements.map(x => new int64(x[1], x[0]).toOctetString()),
    st64measurements.map(x => new int64(x[1], x[0]).toOctetString())
  ];
}

async function benchDriver() {
  const local_res = await benchLocal();
  const remote_res = await benchRemote();

  await promisify(fs.writeFile)(`${outdir}/local_ld32.measurements`, local_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/local_ld64.measurements`, local_res[1].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/local_st32.measurements`, local_res[2].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/local_st64.measurements`, local_res[3].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/remote_ld32.measurements`, remote_res[0].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/remote_ld64.measurements`, remote_res[1].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/remote_st32.measurements`, remote_res[2].join('\n') + '\n');
  await promisify(fs.writeFile)(`${outdir}/remote_st64.measurements`, remote_res[3].join('\n') + '\n');
}

benchDriver().catch(err => console.log(err));
