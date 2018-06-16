const wasmBlob = require('fs').readFileSync(__dirname + '/ref.wasm');
const memory = new WebAssembly.Memory({initial:1});


//

WebAssembly.instantiate(wasmBlob, {js: {memory}}).then(tea => {
  console.log(tea);
  const mem = new Uint32Array(memory.buffer);
  //message
  mem[0] = 0xdeadbeef;
  mem[1] = 0xbeeff00d;
  // key
  mem[2] = 0xd34db33f;
  mem[3] = 0xb33ff33d;
  mem[4] = 0xf000ba12;
  mem[5] = 0xdeadf00d;
  //
  const encrypt = tea.instance.exports.encrypt;
  const decrypt = tea.instance.exports.decrypt;
  //
  console.log(`${mem[0]},${mem[1]}`);
  encrypt();
  console.log(`${mem[0]},${mem[1]}`);
  decrypt();
  console.log(`${mem[0]},${mem[1]}`);
}).catch( err => {
  console.log(err);
  console.log(memory)
});
