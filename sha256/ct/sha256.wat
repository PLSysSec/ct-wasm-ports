(module
  ;; (memory (export "memory") secret 1)
  ;; mem[0..3] datalen, mem[4..11] bitlen, mem[12..43] state
  ;; mem[44..299] m, mem[300..363] data, mem[364..619] k
  ;; mem[620..651] hash (output), mem[652..] input

  (memory (export "memory") secret 1)
  ;; mem[0..31] state, mem[32..287] m, mem[288..351] data
  ;; mem[352..607] k, mem[608..639] hash (output), mem[640..] input

  (global $datalen (mut i32) (i32.const 0))
  (global $bitlen  (mut i64) (i64.const 0))

  ;; arrays
  (global $state        i32  (i32.const 0))
  (global $m            i32  (i32.const 32))
  (global $data         i32  (i32.const 288))
  (global $k            i32  (i32.const 352))
  (global $hash         i32  (i32.const 608))
  (global $input        i32  (i32.const 640))

  (func $init
    (local $i i32)
    (set_global $datalen (i32.const 0))
    (set_global $bitlen (i64.const 0))
    ;; clear old m
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (s32.store (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4))) (s32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    ;; clear old data
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    ;; clear old hash
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 32)))
          (s32.store8 (i32.add (get_global $hash) (get_local $i)) (s32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    (s32.store (i32.add (get_global $state) (i32.const 0)) (s32.const 0x6a09e667))
    (s32.store (i32.add (get_global $state) (i32.const 4)) (s32.const 0xbb67ae85))
    (s32.store (i32.add (get_global $state) (i32.const 8)) (s32.const 0x3c6ef372))
    (s32.store (i32.add (get_global $state) (i32.const 12)) (s32.const 0xa54ff53a))
    (s32.store (i32.add (get_global $state) (i32.const 16)) (s32.const 0x510e527f))
    (s32.store (i32.add (get_global $state) (i32.const 20)) (s32.const 0x9b05688c))
    (s32.store (i32.add (get_global $state) (i32.const 24)) (s32.const 0x1f83d9ab))
    (s32.store (i32.add (get_global $state) (i32.const 28)) (s32.const 0x5be0cd19))
  )

  (func $transform
    (local $a s32)
    (local $b s32)
    (local $c s32)
    (local $d s32)
    (local $e s32)
    (local $f s32)
    (local $g s32)
    (local $h s32)
    (local $i i32)
    (local $j i32)
    (local $t1 s32)
    (local $t2 s32)

    (set_local $i (i32.const 0))
    (set_local $j (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 16)))
          (s32.store
            (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4)))
            (s32.or
              (s32.shl (s32.load8_u (i32.add (get_global $data) (get_local $j))) (s32.const 24))
              (s32.or
                (s32.shl (s32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 1)))) (s32.const 16))
                (s32.or
                  (s32.shl (s32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 2)))) (s32.const 8))
                  (s32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 3))))
                )
              )
            )
          )
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (set_local $j (i32.add (get_local $j) (i32.const 4)))
          (br 0)
      )
    )
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (s32.store
            (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4)))
            (s32.add
              (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 7)) (i32.const 4))))
              (s32.add
                (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 16)) (i32.const 4))))
                (s32.add
                  ;; SIG1(m[i - 2])
                  (s32.xor
                    (s32.rotr (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (s32.const 17))
                    (s32.xor
                      (s32.rotr (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (s32.const 19))
                      (s32.shr_u (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (s32.const 10))
                    )
                  )
                  ;; SIG0(m[i - 15])
                  (s32.xor
                    (s32.rotr (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (s32.const 7))
                    (s32.xor
                      (s32.rotr (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (s32.const 18))
                      (s32.shr_u (s32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (s32.const 3))
                    )
                  )
                )
              )
            )
          )
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )

    (set_local $a (s32.load (i32.add (get_global $state) (i32.const 0)))) 
    (set_local $b (s32.load (i32.add (get_global $state) (i32.const 4))))
    (set_local $c (s32.load (i32.add (get_global $state) (i32.const 8))))
    (set_local $d (s32.load (i32.add (get_global $state) (i32.const 12))))
    (set_local $e (s32.load (i32.add (get_global $state) (i32.const 16))))
    (set_local $f (s32.load (i32.add (get_global $state) (i32.const 20))))
    (set_local $g (s32.load (i32.add (get_global $state) (i32.const 24))))
    (set_local $h (s32.load (i32.add (get_global $state) (i32.const 28))))

    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (set_local $t1
            (s32.add
              (get_local $h)
              (s32.add
                (s32.load (i32.add (get_global $k) (i32.mul (get_local $i) (i32.const 4))))
                (s32.add
                  (s32.load (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4))))
                  (s32.add
                    ;; EP1(e)
                    (s32.xor
                      (s32.rotr (get_local $e) (s32.const 6))
                      (s32.xor
                        (s32.rotr (get_local $e) (s32.const 11))
                        (s32.rotr (get_local $e) (s32.const 25))
                      )
                    )
                    ;; CH(e,f,g)
                    (s32.xor
                      (s32.and (get_local $e) (get_local $f))
                      (s32.and (s32.xor (get_local $e) (s32.const -1)) (get_local $g))
                    )
                  )
                )
              )
            )
          )
          (set_local $t2
            (s32.add
              ;; EP0(a)
              (s32.xor
                (s32.rotr (get_local $a) (s32.const 2))
                (s32.xor
                  (s32.rotr (get_local $a) (s32.const 13))
                  (s32.rotr (get_local $a) (s32.const 22))
                )
              )
              ;; MAJ(a,b,c)
              (s32.xor
                (s32.and (get_local $a) (get_local $b))
                (s32.xor
                  (s32.and (get_local $a) (get_local $c))
                  (s32.and (get_local $b) (get_local $c))
                )
              )
            )
          )
          (set_local $h (get_local $g))
          (set_local $g (get_local $f))
          (set_local $f (get_local $e))
          (set_local $e (s32.add (get_local $d) (get_local $t1)))
          (set_local $d (get_local $c))
          (set_local $c (get_local $b))
          (set_local $b (get_local $a))
          (set_local $a (s32.add (get_local $t1) (get_local $t2)))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )

    (s32.store (i32.add (get_global $state) (i32.const 0)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 0))) (get_local $a)))
    (s32.store (i32.add (get_global $state) (i32.const 4)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 4))) (get_local $b)))
    (s32.store (i32.add (get_global $state) (i32.const 8)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 8))) (get_local $c)))
    (s32.store (i32.add (get_global $state) (i32.const 12)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 12))) (get_local $d)))
    (s32.store (i32.add (get_global $state) (i32.const 16)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 16))) (get_local $e)))
    (s32.store (i32.add (get_global $state) (i32.const 20)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 20))) (get_local $f)))
    (s32.store (i32.add (get_global $state) (i32.const 24)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 24))) (get_local $g)))
    (s32.store (i32.add (get_global $state) (i32.const 28)) (s32.add (s32.load (i32.add (get_global $state) (i32.const 28))) (get_local $h)))
  )

  (func $update (param $inputlen i32)
    (local $i i32)

    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $inputlen)))
          (s32.store8
            (i32.add (get_global $data) (get_global $datalen))
            (s32.load8_u (i32.add (get_global $input) (get_local $i)))
          )
          (set_global $datalen (i32.add (get_global $datalen) (i32.const 1)))
          (if (i32.eq (get_global $datalen) (i32.const 64))
            (then
              (call $transform)
              (set_global $bitlen (i64.add (get_global $bitlen) (i64.const 512)))
              (set_global $datalen (i32.const 0))
            )
          )
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
  )

  (func $final
    (local $i i32)

    (set_local $i (get_global $datalen))
    (if (i32.lt_u (get_local $i) (i32.const 56))
      (then
        (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0x80))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (i32.const 56)))
              (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0x00))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br 0)
          )
        )
      )
      (else
        (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0x80))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
              (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0x00))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br 0)
          )
        )
        (call $transform)
        ;; memset(data, 0, 56)
        (set_local $i (i32.const 0))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (i32.const 56)))
              (s32.store8 (i32.add (get_global $data) (get_local $i)) (s32.const 0x00))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br 0)
          )
        )
      )
    )
    (set_global
      $bitlen
      (i64.add
        (get_global $bitlen)
        (i64.mul (i64.extend_u/i32 (get_global $datalen)) (i64.const 8))
      )
    )
    (s64.store8 (i32.add (get_global $data) (i32.const 63)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 0))))
    (s64.store8 (i32.add (get_global $data) (i32.const 62)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 8))))
    (s64.store8 (i32.add (get_global $data) (i32.const 61)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 16))))
    (s64.store8 (i32.add (get_global $data) (i32.const 60)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 24))))
    (s64.store8 (i32.add (get_global $data) (i32.const 59)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 32))))
    (s64.store8 (i32.add (get_global $data) (i32.const 58)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 40))))
    (s64.store8 (i32.add (get_global $data) (i32.const 57)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 48))))
    (s64.store8 (i32.add (get_global $data) (i32.const 56)) (s64.classify (i64.shr_u (get_global $bitlen) (i64.const 56))))
    (call $transform)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 4)))
          (s32.store8
            (i32.add (get_global $hash) (get_local $i))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 3)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 4)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 7)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 8)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 11)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 12)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 15)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 16)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 19)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 20)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 23)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 24)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 27)) (get_local $i)))
          )
          (s32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 28)))
            (s32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 31)) (get_local $i)))
          )
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
  )

  (export "init" (func $init))
  (export "update" (func $update))
  (export "final" (func $final))
)
