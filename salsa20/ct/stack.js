const assert = require('assert');
const fs = require('fs');
const {promisify} = require('util');
const readFileAsync = promisify(fs.readFile);
const {
  performance,
  PerformanceObserver
} = require('perf_hooks');

async function instance(fname, i) {
  let f = await readFileAsync(__dirname + '/' + fname);
  return await WebAssembly.instantiate(f, i);
}

async function testDriver() {
  const mod = await instance("stack_comp.wasm", {});
  const exp = mod.instance.exports;

  const yes = (() => exp.yes_stack());
  const no = (() => exp.no_stack());
  const nb = exp.no_stack.bind(this);
  const internal = exp.internal_call.bind(this);

  const rounds = 10000000000000;

  const y_rpt = (r) => {
    ((r) => {
      for (let i = 0; i < r; i++) {
        yes();
      }
    })();
  };

  const n_rpt = (r) => {
    ((r) => {
      for (let i = 0; i < r; i++) {
        no();
      }
    })();
  };

  const b_rpt = (r) => {
    ((r) => {
      for (let i = 0; i < r; i++) {
        nb();
      }
    })();
  };

  const yes_wrapped = performance.timerify(y_rpt);
  const no_wrapped = performance.timerify(n_rpt);
  const nb_wrapped = performance.timerify(b_rpt);
  const int_wrapped = performance.timerify(internal);

  /* File name: r_c.data
     r: number of rounds
     c: category of test
     - 'stack' tests the performance of using wasm as a stack machine over
       inlining operations
     - 'bind' tests the performance of using an anonymous function wrapper to 
       bind the timed function to the receiver over using the bind function
     - 'cross' tests the performance of calling a wasm function from JS land 
       over calling it from wasm land
  */
  const cat = 'cross'; // change relevant to test
  const obs = new PerformanceObserver((list) => {
    fs.appendFile('./test_output/' + rounds + 'r_' + cat + '.data', 
        (list.getEntries()[0].duration/rounds) + '\n', err => {
      if (err) throw err;
    });
  });
  obs.observe({ entryTypes: ['function'] });

  /*
     yes = stack machine used
     no  = operations inlined
     nb  = operations inlined with bind
     int = operations inlined with bind and wasm-internal calls
     -----
     STACK tests compare YES and NO
     BIND  tests compare NO  and NB
     CROSS tests compare NB  and INT
  */
  //yes_wrapped(rounds);
  //no_wrapped(rounds);
  nb_wrapped(rounds);
  int_wrapped(rounds);

  obs.disconnect();
}

testDriver().catch(err => console.log(err));
