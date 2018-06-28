(module
  (import "js" "memory" (memory 1))

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
          (i32.store (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4))) (i32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    ;; clear old data
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    ;; clear old hash
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 32)))
          (i32.store8 (i32.add (get_global $hash) (get_local $i)) (i32.const 0))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
    (i32.store (i32.add (get_global $state) (i32.const 0)) (i32.const 0x6a09e667))
    (i32.store (i32.add (get_global $state) (i32.const 4)) (i32.const 0xbb67ae85))
    (i32.store (i32.add (get_global $state) (i32.const 8)) (i32.const 0x3c6ef372))
    (i32.store (i32.add (get_global $state) (i32.const 12)) (i32.const 0xa54ff53a))
    (i32.store (i32.add (get_global $state) (i32.const 16)) (i32.const 0x510e527f))
    (i32.store (i32.add (get_global $state) (i32.const 20)) (i32.const 0x9b05688c))
    (i32.store (i32.add (get_global $state) (i32.const 24)) (i32.const 0x1f83d9ab))
    (i32.store (i32.add (get_global $state) (i32.const 28)) (i32.const 0x5be0cd19))
  )

  (func $transform
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

    (set_local $i (i32.const 0))
    (set_local $j (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 16)))
          (i32.store
            (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4)))
            (i32.or
              (i32.shl (i32.load8_u (i32.add (get_global $data) (get_local $j))) (i32.const 24))
              (i32.or
                (i32.shl (i32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 1)))) (i32.const 16))
                (i32.or
                  (i32.shl (i32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 2)))) (i32.const 8))
                  (i32.load8_u (i32.add (get_global $data) (i32.add (get_local $j) (i32.const 3))))
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
            (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4)))
            (i32.add
              (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 7)) (i32.const 4))))
              (i32.add
                (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 16)) (i32.const 4))))
                (i32.add
                  ;; SIG1(m[i - 2])
                  (i32.xor
                    (i32.rotr (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 17))
                    (i32.xor
                      (i32.rotr (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 19))
                      (i32.shr_u (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 2)) (i32.const 4)))) (i32.const 10))
                    )
                  )
                  ;; SIG0(m[i - 15])
                  (i32.xor
                    (i32.rotr (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 7))
                    (i32.xor
                      (i32.rotr (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 18))
                      (i32.shr_u (i32.load (i32.add (get_global $m) (i32.mul (i32.sub (get_local $i) (i32.const 15)) (i32.const 4)))) (i32.const 3))
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

    (set_local $a (i32.load (i32.add (get_global $state) (i32.const 0)))) 
    (set_local $b (i32.load (i32.add (get_global $state) (i32.const 4))))
    (set_local $c (i32.load (i32.add (get_global $state) (i32.const 8))))
    (set_local $d (i32.load (i32.add (get_global $state) (i32.const 12))))
    (set_local $e (i32.load (i32.add (get_global $state) (i32.const 16))))
    (set_local $f (i32.load (i32.add (get_global $state) (i32.const 20))))
    (set_local $g (i32.load (i32.add (get_global $state) (i32.const 24))))
    (set_local $h (i32.load (i32.add (get_global $state) (i32.const 28))))

    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
          (set_local $t1
            (i32.add
              (get_local $h)
              (i32.add
                (i32.load (i32.add (get_global $k) (i32.mul (get_local $i) (i32.const 4))))
                (i32.add
                  (i32.load (i32.add (get_global $m) (i32.mul (get_local $i) (i32.const 4))))
                  (i32.add
                    ;; EP1(e)
                    (i32.xor
                      (i32.rotr (get_local $e) (i32.const 6))
                      (i32.xor
                        (i32.rotr (get_local $e) (i32.const 11))
                        (i32.rotr (get_local $e) (i32.const 25))
                      )
                    )
                    ;; CH(e,f,g)
                    (i32.xor
                      (i32.and (get_local $e) (get_local $f))
                      (i32.and (i32.xor (get_local $e) (i32.const -1)) (get_local $g))
                    )
                  )
                )
              )
            )
          )
          (set_local $t2
            (i32.add
              ;; EP0(a)
              (i32.xor
                (i32.rotr (get_local $a) (i32.const 2))
                (i32.xor
                  (i32.rotr (get_local $a) (i32.const 13))
                  (i32.rotr (get_local $a) (i32.const 22))
                )
              )
              ;; MAJ(a,b,c)
              (i32.xor
                (i32.and (get_local $a) (get_local $b))
                (i32.xor
                  (i32.and (get_local $a) (get_local $c))
                  (i32.and (get_local $b) (get_local $c))
                )
              )
            )
          )
          (set_local $h (get_local $g))
          (set_local $g (get_local $f))
          (set_local $f (get_local $e))
          (set_local $e (i32.add (get_local $d) (get_local $t1)))
          (set_local $d (get_local $c))
          (set_local $c (get_local $b))
          (set_local $b (get_local $a))
          (set_local $a (i32.add (get_local $t1) (get_local $t2)))
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )

    (i32.store (i32.add (get_global $state) (i32.const 0)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 0))) (get_local $a)))
    (i32.store (i32.add (get_global $state) (i32.const 4)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 4))) (get_local $b)))
    (i32.store (i32.add (get_global $state) (i32.const 8)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 8))) (get_local $c)))
    (i32.store (i32.add (get_global $state) (i32.const 12)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 12))) (get_local $d)))
    (i32.store (i32.add (get_global $state) (i32.const 16)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 16))) (get_local $e)))
    (i32.store (i32.add (get_global $state) (i32.const 20)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 20))) (get_local $f)))
    (i32.store (i32.add (get_global $state) (i32.const 24)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 24))) (get_local $g)))
    (i32.store (i32.add (get_global $state) (i32.const 28)) (i32.add (i32.load (i32.add (get_global $state) (i32.const 28))) (get_local $h)))
  )

  (func $update (param $inputlen i32)
    (local $i i32)

    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $inputlen)))
          (i32.store8
            (i32.add (get_global $data) (get_global $datalen))
            (i32.load8_u (i32.add (get_global $input) (get_local $i)))
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
        (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0x80))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (i32.const 56)))
              (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0x00))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br 0)
          )
        )
      )
      (else
        (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0x80))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
              (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0x00))
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
              (i32.store8 (i32.add (get_global $data) (get_local $i)) (i32.const 0x00))
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
    (i64.store8 (i32.add (get_global $data) (i32.const 63)) (i64.shr_u (get_global $bitlen) (i64.const 0)))
    (i64.store8 (i32.add (get_global $data) (i32.const 62)) (i64.shr_u (get_global $bitlen) (i64.const 8)))
    (i64.store8 (i32.add (get_global $data) (i32.const 61)) (i64.shr_u (get_global $bitlen) (i64.const 16)))
    (i64.store8 (i32.add (get_global $data) (i32.const 60)) (i64.shr_u (get_global $bitlen) (i64.const 24)))
    (i64.store8 (i32.add (get_global $data) (i32.const 59)) (i64.shr_u (get_global $bitlen) (i64.const 32)))
    (i64.store8 (i32.add (get_global $data) (i32.const 58)) (i64.shr_u (get_global $bitlen) (i64.const 40)))
    (i64.store8 (i32.add (get_global $data) (i32.const 57)) (i64.shr_u (get_global $bitlen) (i64.const 48)))
    (i64.store8 (i32.add (get_global $data) (i32.const 56)) (i64.shr_u (get_global $bitlen) (i64.const 56)))
    (call $transform)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 4)))
          (i32.store8
            (i32.add (get_global $hash) (get_local $i))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 3)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 4)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 7)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 8)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 11)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 12)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 15)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 16)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 19)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 20)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 23)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 24)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 27)) (get_local $i)))
          )
          (i32.store8
            (i32.add (get_global $hash) (i32.add (get_local $i) (i32.const 28)))
            (i32.load8_u (i32.sub (i32.add (get_global $state) (i32.const 31)) (get_local $i)))
          )
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
      )
    )
  )

  (export "init" (func $init))
  (export "transform" (func $transform))
  (export "update" (func $update))
  (export "final" (func $final))
)
