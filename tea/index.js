const wasmBlob = require('fs').readFileSync(__dirname + '/ref.wasm');
const memory = new WebAssembly.Memory({initial:1});


//

WebAssembly.instantiate(wasmBlob, {js: {memory}}).then(tea => {
  console.log(tea);
  const mem = new Uint32Array(memory.buffer);
  mem[0] = 3;
  mem[1] = 7;
  console.log(mem);
  //
  const add = tea.instance.exports.add;
  console.log(add());
}).catch( err => {
  console.log(err);
  console.log(memory)
});
