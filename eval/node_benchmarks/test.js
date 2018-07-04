const nacl_wasm = require('../dist/nacl-wasm.js');
const nacl = require('./nacl-fast.js');
const { performance } = require('perf_hooks');
const crypto = require('crypto');
const getRandomValues = require('get-random-values');

(function () {

  function compareArrays(arr1, arr2) {
    if (!arr1 || !arr2 || arr1.length !== arr2.length) {
      console.log(arr1);
      console.log(arr2);
      return false;
    }
    const length = arr1.length;
    for (let i = 0; i < length; i++) {
      if (arr1[i] !== arr2[i]) {
        console.log(i, arr1[i], arr2[i]);
        console.log(arr1);
        console.log(arr2);
        return false;
      }
    }
    return true;
  }

  function fillRandom(array) {
    for (let i = 0; i < array.length; i++) {
      array[i] = Math.floor(Math.random() * 256);
    }
  }

  function getPerformanceString(names) {
    let durationOfFirst;
    const performanceString = names.map((name, index) => {
      const entries = performance.getEntriesByName(name + 'Measure');
      const duration = entries[entries.length - 1].duration;
      if (index === 0) {
        durationOfFirst = duration;
      }
      const durationString = name + ': ' + (Math.round(duration * 1000) / 1000) + 'ms'
      return durationString + (index > 0 ?
        ' ' + (Math.round(duration / durationOfFirst * 10) / 10) + 'x' :
        ''
      );
    }).join('; ');

    performance.clearMarks();
    performance.clearMeasures();

    return '(' + performanceString + ')';
  }

  function testCryptoCoreHSalsa20() {
    const p = new Uint8Array(16);
    const k = new Uint8Array(32);
    const c = new Uint8Array(16);

    fillRandom(p);
    fillRandom(k);
    fillRandom(c);

    let o;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) o = nacl_wasm.lowlevel.crypto_core_hsalsa20(p, k, c);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const o2 = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_core_hsalsa20(o2, p, k, c);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_core_hsalsa20',
      compareArrays(o, o2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoStreamSalsa20() {
    const d = 23423323;
    const n = new Uint8Array(8);
    const k = new Uint8Array(32);

    fillRandom(n);
    fillRandom(k);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_stream_salsa20(d, n, k);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_stream_salsa20(c2, 0, d, n, k);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_stream_salsa20',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoStreamSalsa20Xor() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(8);
    const k = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(k);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_stream_salsa20_xor(m, n, k)
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_stream_salsa20_xor(c2, 0, m, 0, d, n, k);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_stream_salsa20_xor',
      compareArrays(c, c2) ? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testCryptoStream() {
    const d = 23423323;

    const n = new Uint8Array(24);
    const k = new Uint8Array(32);

    fillRandom(n);
    fillRandom(k);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_stream(d, n, k);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_stream(c2, 0, d, n, k);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_stream',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoStreamXor() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const k = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(k);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_stream_xor(m, n, k);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_stream_xor(c2, 0, m, 0, d, n, k);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_stream_xor',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoOnetimeAuth() {
    const bytes = 23423323;

    const m = new Uint8Array(bytes);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(key);

    performance.mark('wasmMark');
    const mac = nacl_wasm.lowlevel.crypto_onetimeauth(m, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const mac2 = new Uint8Array(16);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_onetimeauth(mac2, 0, m, 0, bytes, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_onetimeauth',
      compareArrays(mac, mac2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoOnetimeAuthVerify() {
    const bytes = 23423323;

    const wrongMac = new Uint8Array(16);
    const m = new Uint8Array(bytes);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(key);
    fillRandom(wrongMac);
    const mac = nacl_wasm.lowlevel.crypto_onetimeauth(m, key);
    if (wrongMac[0] === mac[0]) {
      wrongMac[0]++;
    }

    performance.mark('wasmMark');
    const t = nacl_wasm.lowlevel.crypto_onetimeauth_verify(mac, m, key);
    const f = nacl_wasm.lowlevel.crypto_onetimeauth_verify(wrongMac, m, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const t2 = nacl.lowlevel.crypto_onetimeauth_verify(mac, 0, m, 0, bytes, key);
    const f2 = nacl.lowlevel.crypto_onetimeauth_verify(wrongMac, 0, m, 0, bytes, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_onetimeauth_verify', t === t2 && f === f2 ? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testCryptoSecretBox() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(key);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_secretbox(m, n, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_secretbox(c2, m, d, n, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_secretbox',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoSecretBoxOpen() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(key);
    for (let i = 0; i < 32; i++) {
      m[i] = 0;
    }

    const c = nacl_wasm.lowlevel.crypto_secretbox(m, n, key);

    performance.mark('wasmMark');
    const m2 = nacl_wasm.lowlevel.crypto_secretbox_open(c, n, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let m3 = new Uint8Array(d);
    performance.mark('jsMark');
    m3 = nacl.lowlevel.crypto_secretbox_open(m3, c, d, n, key) ? null : m3;
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_secretbox_open',
      m2 === m3 || compareArrays(m2, m3) ? 'Equal' : 'Not equal', 
      getPerformanceString(['wasm', 'js']));
  }

  function testNaclSecretbox() {
    const d = 23423323;

    const msg = new Uint8Array(d);
    const nonce = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(msg);
    fillRandom(nonce);
    fillRandom(key);

    performance.mark('wasmMark');
    const c = nacl_wasm.secretbox(msg, nonce, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const c2 = nacl.secretbox(msg, nonce, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_secretbox',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclSecretboxOpen() {
    const d = 23423323;

    const msg = new Uint8Array(d);
    const nonce = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(msg);
    fillRandom(nonce);
    fillRandom(key);

    const c = nacl_wasm.secretbox(msg, nonce, key);

    performance.mark('wasmMark');
    const msg2 = nacl_wasm.secretbox.open(c, nonce, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const msg3 = nacl.secretbox.open(c, nonce, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_secretbox_open',
      compareArrays(msg2, msg3) ? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testVerify() {
    const d = 23423323;

    const x = new Uint8Array(d);
    const y = new Uint8Array(d);
    const y32 = new Uint8Array(d);
    const y16 = new Uint8Array(d);
    fillRandom(x);
    y.set(x);
    y32.set(x);
    y16.set(x);
    index = Math.floor(Math.random() * d);
    y[index] ^= Math.floor(Math.random() * 255) + 1;
    index32 = Math.floor(Math.random() * 32);
    y32[index32] ^= Math.floor(Math.random() * 255) + 1;
    index16 = Math.floor(Math.random() * 16);
    y16[index16] ^= Math.floor(Math.random() * 255) + 1;

    performance.mark('wasmMark');
    const t = nacl_wasm.verify(x, x);
    const f = nacl_wasm.verify(x, y);
    const t3 = nacl_wasm.lowlevel.crypto_verify_32(x.subarray(0, 32), x.subarray(0, 32));
    const f3 = nacl_wasm.lowlevel.crypto_verify_32(x.subarray(0, 32), y32);
    const t5 = nacl_wasm.lowlevel.crypto_verify_16(x.subarray(0, 16), x.subarray(0, 16));
    const f5 = nacl_wasm.lowlevel.crypto_verify_16(x.subarray(0, 16), y16);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const t2 = nacl.verify(x, x);
    const f2 = nacl.verify(x, y);
    const t4 = nacl.lowlevel.crypto_verify_32(x.subarray(0, 32), 0, x.subarray(0, 32), 0);
    const f4 = nacl.lowlevel.crypto_verify_32(x.subarray(0, 32), 0, y32, 0);
    const t6 = nacl.lowlevel.crypto_verify_16(x.subarray(0, 16), 0, x.subarray(0, 16), 0);
    const f6 = nacl.lowlevel.crypto_verify_16(x.subarray(0, 16), 0, y16, 0);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_verify',
      t === t2 && f === f2 && t3 === t4 && f3 === f4 && t5 === t6 && f5 === f6 ?
      'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js'])
    );
  }

  function testCryptoScalarMult() {
    const n = new Uint8Array(32);
    const p = new Uint8Array(32);

    fillRandom(n);
    fillRandom(p);

    let q;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) q = nacl_wasm.lowlevel.crypto_scalarmult(n, p);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const q2 = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_scalarmult(q2, n, p);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_scalarmult',
      compareArrays(q, q2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoScalarMultBase() {
    const n = new Uint8Array(32);

    fillRandom(n);

    let q;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) q = nacl_wasm.lowlevel.crypto_scalarmult_base(n);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const q2 = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_scalarmult_base(q2, n);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_scalarmult_base',
      compareArrays(q, q2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoBoxBeforenm() {
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(y);
    fillRandom(x);

    let k;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) k = nacl_wasm.lowlevel.crypto_box_beforenm(y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const k2 = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_box_beforenm(k2, y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_box_beforenm',
      compareArrays(k, k2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoBoxAfternm() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(key);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_box_afternm(m, n, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_box_afternm(c2, m, d, n, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_box_afternm',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoBox() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(y);
    fillRandom(x);

    performance.mark('wasmMark');
    const c = nacl_wasm.lowlevel.crypto_box(m, n, y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const c2 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_box(c2, m, m.length, n, y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_box',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoBoxOpen() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(y);
    fillRandom(x);
    for (let i = 0; i < 32; i++) {
      m[i] = 0;
    }

    const c = nacl_wasm.lowlevel.crypto_box(m, n, y, x);

    performance.mark('wasmMark');
    const m2 = nacl_wasm.lowlevel.crypto_box_open(c, n, y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const m3 = new Uint8Array(d);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_box_open(m3, c, c.length, n, y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_box_open',
      compareArrays(m2, m3) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoBoxKeypair() {
    let keyPair;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) keyPair = nacl_wasm.lowlevel.crypto_box_keypair();
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const x = new Uint8Array(32);
    const y = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_box_keypair(y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_box_keypair', 'Not comparable', getPerformanceString(['wasm', 'js']));
  }

  function testCryptoHash() {
    const d = 23423323;
    const m = new Uint8Array(d);
    fillRandom(m);

    performance.mark('nativeMark');
    let hash = crypto.createHash('sha512');
    hash.update(m);
    performance.mark('nativeEnd');
    hash = hash.digest('hex');
    hash_res = new Uint8Array(64);
    for (let i = 0, j = 0; i < hash_res.length; i++, j += 2) {
      const h1 = parseInt(hash[j], 16);
      const h2 = parseInt(hash[j+1], 16);
      hash_res[i] = ((h1 << 4) | (h2 << 0));
    }
    performance.measure('nativeMeasure', 'nativeMark', 'nativeEnd');

    performance.mark('wasmMark');
    const out = nacl_wasm.lowlevel.crypto_hash(m);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const out2 = new Uint8Array(64);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_hash(out2, m, m.length);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_hash',
      compareArrays(out, out2) && compareArrays(out, hash_res)? 'Equal' : 'Not equal', 
      getPerformanceString(['wasm', 'native', 'js']));
  }

  function testCryptoSign() {
    const d = 23423323;
    const msg = new Uint8Array(d);
    const sk = new Uint8Array(64);
    fillRandom(msg);
    fillRandom(sk);

    performance.mark('wasmMark');
    const sm = nacl_wasm.lowlevel.crypto_sign(msg, sk);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const sm2 = new Uint8Array(d + 64);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_sign(sm2, msg, msg.length, sk);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_sign',
      compareArrays(sm, sm2)? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testCryptoSignKeypair() {
    const sk = new Uint8Array(64);
    fillRandom(sk);

    let keyPair;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) keyPair = nacl_wasm.lowlevel.crypto_sign_keypair(sk, true);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const pk = new Uint8Array(32);
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) nacl.lowlevel.crypto_sign_keypair(pk, sk, true);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_sign_keypair',
      compareArrays(pk, keyPair[0]) && compareArrays(sk, keyPair[1])? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testCryptoSignOpen() {
    const d = 23423323;
    const msg = new Uint8Array(d);
    let sk = new Uint8Array(64);
    fillRandom(msg);

    const keyPair = nacl_wasm.lowlevel.crypto_sign_keypair(sk);
    const publicKey = keyPair[0];
    const secretKey = keyPair[1];

    const sm = nacl_wasm.lowlevel.crypto_sign(msg, secretKey);

    performance.mark('wasmMark');
    const msg1 = nacl_wasm.lowlevel.crypto_sign_open(sm, publicKey);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    const msg2 = new Uint8Array(d + 64);
    performance.mark('jsMark');
    nacl.lowlevel.crypto_sign_open(msg2, sm, sm.length, publicKey);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test crypto_sign_open',
      compareArrays(msg1, msg2.slice(0, msg2.length - 64))? 'Equal' : 'Not equal',
      getPerformanceString(['wasm', 'js']));
  }

  function testNaclScalarMult() {
    const n = new Uint8Array(32);
    const p = new Uint8Array(32);

    fillRandom(n);
    fillRandom(p);

    let q;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) q = nacl_wasm.scalarMult(n, p);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let q2;
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) q2 = nacl.scalarMult(n, p);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_scalarmult',
      compareArrays(q, q2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclScalarMultBase() {
    const n = new Uint8Array(32);

    fillRandom(n);

    let q;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) q = nacl_wasm.scalarMult.base(n);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let q2;
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) q2 = nacl.scalarMult.base(n);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_scalarmult_base',
      compareArrays(q, q2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBox() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(y);
    fillRandom(x);

    performance.mark('wasmMark');
    const c = nacl_wasm.box(m, n, y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const c2 = nacl.box(m, n, y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBoxBefore() {
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(y);
    fillRandom(x);

    let k;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) k = nacl_wasm.box.before(y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let k2;
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) k2 = nacl.box.before(y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box_before',
      compareArrays(k, k2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBoxAfter() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const key = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(key);

    performance.mark('wasmMark');
    const c = nacl_wasm.box.after(m, n, key);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const c2 = nacl.box.after(m, n, key);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box_after',
      compareArrays(c, c2) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBoxOpen() {
    const d = 23423323;

    const m = new Uint8Array(d);
    const n = new Uint8Array(24);
    const y = new Uint8Array(32);
    const x = new Uint8Array(32);

    fillRandom(m);
    fillRandom(n);
    fillRandom(y);
    fillRandom(x);

    const c = nacl_wasm.box(m, n, y, x);

    performance.mark('wasmMark');
    const m2 = nacl_wasm.box.open(c, n, y, x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const m3 = nacl.box.open(c, n, y, x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box_open',
      compareArrays(m2, m3) ? 'Equal' : 'Not equal', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBoxKeyPair() {
    let keyPair;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) keyPair = nacl_wasm.box.keyPair();
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let keyPair2;
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) keyPair2 = nacl.box.keyPair();
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box_keypair', 'Not comparable', getPerformanceString(['wasm', 'js']));
  }

  function testNaclBoxKeyPairFromSecretKey() {
    const x = new Uint8Array(32);
    fillRandom(x);

    let keyPair;
    performance.mark('wasmMark');
    for (let i = 0; i < 100; i++) keyPair = nacl_wasm.box.keyPair.fromSecretKey(x);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    let keyPair2;
    performance.mark('jsMark');
    for (let i = 0; i < 100; i++) keyPair2 = nacl.box.keyPair.fromSecretKey(x);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_box_keypair_fromsecretkey',
      compareArrays(keyPair.publicKey, keyPair2.publicKey) ? 'Equal' : 'Not equal', 
      getPerformanceString(['wasm', 'js']));
  }

  function testNaclHash() {
    const d = 23423323;
    const m = new Uint8Array(d);
    fillRandom(m);

    performance.mark('wasmMark');
    const out = nacl_wasm.hash(m);
    performance.mark('wasmEnd');
    performance.measure('wasmMeasure', 'wasmMark', 'wasmEnd');

    performance.mark('jsMark');
    const out2 = nacl.hash(m);
    performance.mark('jsEnd');
    performance.measure('jsMeasure', 'jsMark', 'jsEnd');

    console.log('test nacl_hash',
      compareArrays(out, out2) ? 'Equal' : 'Not equal', 
      getPerformanceString(['wasm', 'js']));
  }

  // Instantiate
  nacl_wasm.instanceReady()
    .then(() => {
      //low level
      testCryptoCoreHSalsa20();
      testCryptoStreamSalsa20();
      testCryptoStreamSalsa20Xor();
      testCryptoStream();
      testCryptoStreamXor();
      testCryptoOnetimeAuth();
      testCryptoOnetimeAuthVerify();
      testCryptoSecretBox();
      testCryptoSecretBoxOpen();
      testVerify();
      testCryptoScalarMult();
      testCryptoScalarMultBase();
      testCryptoBoxBeforenm();
      testCryptoBoxAfternm();
      testCryptoBox();
      testCryptoBoxOpen();
      testCryptoBoxKeypair();
      testCryptoHash();
      testCryptoSign();
      testCryptoSignKeypair();
      testCryptoSignOpen();

      
      //high level
      testNaclSecretbox();
      testNaclSecretboxOpen();
      testNaclScalarMult();
      testNaclScalarMultBase();
      testNaclBox();
      testNaclBoxBefore();
      testNaclBoxAfter();
      testNaclBoxOpen();
      testNaclBoxKeyPair();
      testNaclBoxKeyPairFromSecretKey();
      testNaclHash();
  });
})();
