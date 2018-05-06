(module
  (memory 1)
  ;; mem[0..3] datalen, mem[4..11] bitlen, mem[12..43] state
  ;; mem[44..299] m, mem[300..363] data

  ;; TODO: figure out how to do global arrays (for the k array)

  (func $init
    (i32.store (i32.const 0) (i32.const 0)) ;; datalen = 0
    (i64.store (i32.const 4) (i64.const 0)) ;; bitlen = 0
    (i32.store (i32.const 12) (i32.const 0x6a09e667))
    (i32.store (i32.const 16) (i32.const 0xbb67ae85))
    (i32.store (i32.const 20) (i32.const 0x3c6ef372))
    (i32.store (i32.const 24) (i32.const 0xa54ff53a))
    (i32.store (i32.const 28) (i32.const 0x510e527f))
    (i32.store (i32.const 32) (i32.const 0x9b05688c))
    (i32.store (i32.const 36) (i32.const 0x1f83d9ab))
    (i32.store (i32.const 40) (i32.const 0x5be0cd19))
  )

  (func $transform (param $data i32)
    (local $a i32)
    (local $b i32)
    (local $c i32)
    (local $d i32)
    (local $e i32)
    (local $f i32)
    (local $g i32)
    (local $h i32)
    (local $i i32)
    (local $j i32)
    (local $t1 i32)
    (local $t2 i32)
    (local $m i32)

    (set_local $m (i32.const 44))
    (set_local $i (i32.const 0))
    (set_local $j (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 16)))
          (i32.store
            (i32.add (get_local $m) (i32.mul (get_local $i) (i32.const 4)))
            (i32.or
              (i32.shl (i32.load (i32.add (get_local $data) (get_local $j))) (i32.const 24))
              (i32.or
                (i32.shl (i32.load (i32.add (get_local $data) (i32.add (get_local $j) (i32.const 2)))) (i32.const 16))
                (i32.or
                  (i32.shl (i32.load (i32.add (get_local $data) (i32.add (get_local $j) (i32.const 2)))) (i32.const 8))
                  (i32.load (i32.add (get_local $data) (i32.add (get_local $j) (i32.const 3))))
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
          (i32.store
            (i32.add (get_local $m) (i32.mul (get_local $i) (i32.const 4)))
            (i32.add
              (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 7)) (i32.const 4))))
              (i32.add
                (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 16)) (i32.const 4))))
                (i32.add
                  ;; SIG1(m[i - 2])
                  (i32.xor
                    (i32.rotr (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 17))
                    (i32.xor
                      (i32.rotr (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 19))
                      (i32.shr_u (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 10))
                    )
                  )
                  ;; SIG0(m[i - 15])
                  (i32.xor
                    (i32.rotr (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 7))
                    (i32.xor
                      (i32.rotr (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 18))
                      (i32.shr_u (i32.load (i32.add (get_local $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 3))
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

    (set_local $a (i32.load (i32.const 12)))
    (set_local $b (i32.load (i32.const 16)))
    (set_local $c (i32.load (i32.const 20)))
    (set_local $d (i32.load (i32.const 24)))
    (set_local $e (i32.load (i32.const 28)))
    (set_local $f (i32.load (i32.const 32)))
    (set_local $g (i32.load (i32.const 36)))
    (set_local $h (i32.load (i32.const 40)))

    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          ;; t1 = h + EP1(e) + CH(e,f,g) + k[i] + m[i]
          ;; TODO
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )

    ;; TODO
  )

  (func $read32 (param i32) (result i32)
    (i32.load (get_local 0))
  )

  (func $read64 (param i32) (result i64)
    (i64.load (get_local 0))
  )

  (export "init" (func $init))
  ;; (export "update" (func $update))
  ;; (export "final" (func $final))
  (export "read32" (func $read32))
  (export "read64" (func $read64))
)
