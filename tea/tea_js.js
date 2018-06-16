exports.init = (cb) => {
  exports.encrypt = function (v, k) {
    let v0=v[0], v1=v[1], sum=0, i;           /* set up */
    const delta=0x9e3779b9;                     /* a key schedule constant */
    let k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
      sum += delta;
      v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
      v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    return [v0, v1];
  }

  exports.decrypt = function (v, k) {
    let v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
    const delta=0x9e3779b9;                     /* a key schedule constant */
    let k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
      v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
      v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
      sum -= delta;
    }                                              /* end cycle */
    return [v0, v1];
  }
  cb();
};
