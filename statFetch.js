#!/usr/bin/env node
// toy to practice using Node to access system data

'use strict'
const fs = require('fs');
const spawn = require('child_process').spawn

const getCpuInfo = () => {
  const specs = { };
  fs.readFile('/proc/cpuinfo', (err, data) => { // easier with `lscpu`
    if (err)  throw err; 
    specs.cpu = data.toString().match(/model name\s*: (.+GHz)/)[1];

    log(specs);
  });
};

const getMemInfo = () => {
  const specs = { };
  const mem = spawn('free');
  let output = '';

  mem.stdout.on('data', chunk => output += chunk);
  mem.on('close', () => {
    [specs.memTotal, specs.memUsed ] = output.match(/\d+/g);

    log(specs);
  });
};

const getUname = () => {
  const specs = { };
  const uname = spawn('uname', [ '-a']);
  let buffer = '';

  uname.stdout.on('data', chunk => buffer += chunk);
  uname.on('close', () => {
    [specs.host, specs.kernel, specs.distro] = buffer.split(/\s+/).slice(1, 4);

    log(specs);
  });
};

const getEnv = () => {
  const specs = { };
  const env = spawn('printenv');
  let buffer = '';

  env.stdout.on('data', chunk => buffer += chunk);
  env.on('close', () => {
    let values = buffer.match(/^(TERM|SHELL|XDG_CURRENT_DESKTOP).+/gm)
      .map( (v) => {return v.split('=')} );

    values.forEach( (pair) => {
      let [key, value] = pair;
      specs[key] = value;
    });

    log(specs);
  });
};

const getPackCount = () => {
  const specs = { };
  const apt = spawn('dpkg-query', ['-l']);
  let buffer = '';

  apt.on('data', chunk => buffer += chunk);
  apt.on('close', () => { 
    specs.pack = buffer.split(/\n/).length;

    log(specs);
  });
};

const log = (obj) => {
  for (let key in obj) {
    console.log(`${key}: ${obj[key]}`);
  }
};

getMemInfo();
getCpuInfo();
getUname();
getEnv();
// getPackCount();


// TODO: 
//   - is there a better solution to async? Currently each function does too much(?)
//   - debug getPackCount; it never returns?
//   - pretty up the output
