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
  let f = await readFileAsync(__dirname + '/salsa20/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function benchmarkDriver(is_sec) {
  const bytes = 64;
  const number_measurements = 1e5;
  const rounds = 10;

  const length = Math.ceil(bytes / 4);
  const key_size = 8;
  const iv_size = 2;

  const nonce = new Uint8Array(iv_size * 4);
  for (let i = 0; i < iv_size * 4; i++) {
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
    keys.push(new Uint8Array(key_size * 4));
    if (classes[i] == 0) {
      for (let j = 0; j < key_size * 4; j++) {
        keys[i][j] = 0;
      }
    } else {
      for (let j = 0; j < key_size * 4; j++) {
        keys[i][j] = getRand(0xff);
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
    /*
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
    */
    mem8[0 ] = 0x65;
    mem8[1 ] = 0x78;
    mem8[2 ] = 0x70;
    mem8[3 ] = 0x61;
    mem8[4 ] = keys[i][0 ];
    mem8[5 ] = keys[i][1 ];
    mem8[6 ] = keys[i][2 ];
    mem8[7 ] = keys[i][3 ];
    mem8[8 ] = keys[i][4 ];
    mem8[9 ] = keys[i][5 ];
    mem8[10] = keys[i][6 ];
    mem8[11] = keys[i][7 ];
    mem8[12] = keys[i][8 ];
    mem8[13] = keys[i][9 ];
    mem8[14] = keys[i][10];
    mem8[15] = keys[i][11];
    mem8[16] = keys[i][12];
    mem8[17] = keys[i][13];
    mem8[18] = keys[i][14];
    mem8[19] = keys[i][15];
    mem8[20] = 0x6e;
    mem8[21] = 0x64;
    mem8[22] = 0x20;
    mem8[23] = 0x33;
    mem8[24] = nonce[0];
    mem8[25] = nonce[1];
    mem8[26] = nonce[2];
    mem8[27] = nonce[3];
    mem8[28] = nonce[4];
    mem8[29] = nonce[5];
    mem8[30] = nonce[6];
    mem8[31] = nonce[7];
    mem8[32] = 0;
    mem8[33] = 0;
    mem8[34] = 0;
    mem8[35] = 0;
    mem8[36] = 0;
    mem8[37] = 0;
    mem8[38] = 0;
    mem8[39] = 0;
    mem8[40] = 0x32;
    mem8[41] = 0x2d;
    mem8[42] = 0x62;
    mem8[43] = 0x79;
    mem8[44] = keys[i][16];
    mem8[45] = keys[i][17];
    mem8[46] = keys[i][18];
    mem8[47] = keys[i][19];
    mem8[48] = keys[i][20];
    mem8[49] = keys[i][21];
    mem8[50] = keys[i][22];
    mem8[51] = keys[i][23];
    mem8[52] = keys[i][24];
    mem8[53] = keys[i][25];
    mem8[54] = keys[i][26];
    mem8[55] = keys[i][27];
    mem8[56] = keys[i][28];
    mem8[57] = keys[i][29];
    mem8[58] = keys[i][30];
    mem8[59] = keys[i][31];
    mem8[60] = 0x74;
    mem8[61] = 0x65;
    mem8[62] = 0x20;
    mem8[63] = 0x6b;

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
