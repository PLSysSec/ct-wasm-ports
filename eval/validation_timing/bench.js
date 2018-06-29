// Benchmarking the validation step of webassembly:
//      node bench.js 1000 test1.wasm test2.wasm

const { readFileSync } = require('fs');
const { performance, PerformanceObserver } = require('perf_hooks');


let current_trials = [];
const timed_validate = performance.timerify(WebAssembly.validate);
const obs = new PerformanceObserver((list) => {
    current_trials.push(list.getEntries()[0].duration);
    performance.clearFunctions();
});
obs.observe({ entryTypes: ['function'] });


const trial_count = process.argv[2];
for (let file of process.argv.slice(3)) {
    buffer = readFileSync(file);
    if (!WebAssembly.validate(buffer)) {
        console.log('');
        continue;
    }
    for (let i = 0; i < trial_count; i++) {
        timed_validate(buffer);
    }

    let avg = current_trials.reduce((a, b) => a + b, 0) / current_trials.length;
    console.log(avg);
    current_trials = [];
}