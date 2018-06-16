const wasmBlob = require('fs').readFileSync(__dirname + '/ref.wasm');
const memory = new WebAssembly.Memory({initial:1});

exports.init = (cb) => {
  WebAssembly.instantiate(wasmBlob, {js: {memory}}).then(tea => {
    const mem = new Uint32Array(memory.buffer);
    exports.encrypt = function (v, k) {
      //message
      mem[0] = v[0];
      mem[1] = v[1];
      // key
      mem[2] = k[0];
      mem[3] = k[1];
      mem[4] = k[2];
      mem[5] = k[3];
      // encrypt
      tea.instance.exports.encrypt();
      return [mem[0], mem[1]];
    };
    exports.decrypt = function (v, k) {
      //message
      mem[0] = v[0];
      mem[1] = v[1];
      // key
      mem[2] = k[0];
      mem[3] = k[1];
      mem[4] = k[2];
      mem[5] = k[3];
      // encrypt
      tea.instance.exports.decrypt();
      return [mem[0], mem[1]];
    };
    cb();
  }).catch(err => {
    throw err;
  });
};
