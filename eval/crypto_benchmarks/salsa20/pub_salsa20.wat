(module
  (import "js" "memory" (memory 2))
  
  ;; rounds function
  (func $salsa20 untrusted 
    (local $i i32)
    (local $l0 i32)
    (local $l1 i32)
    (local $l2 i32)
    (local $l3 i32)
    (local $l4 i32)
    (local $l5 i32)
    (local $l6 i32)
    (local $l7 i32)
    (local $l8 i32)
    (local $l9 i32)
    (local $l10 i32)
    (local $l11 i32)
    (local $l12 i32)
    (local $l13 i32)
    (local $l14 i32)
    (local $l15 i32)
    (local $c0 i32)
    (local $c1 i32)
    (local $c2 i32)
    (local $c3 i32)
    (local $c4 i32)
    (local $c5 i32)
    (local $c6 i32)
    (local $c7 i32)
    (local $c8 i32)
    (local $c9 i32)
    (local $c10 i32)
    (local $c11 i32)
    (local $c12 i32)
    (local $c13 i32)
    (local $c14 i32)
    (local $c15 i32)
    ;; init local 'u32 x[16]' --- (offset 16 - 31)
    (set_local $l0 (tee_local $c0 (i32.load (i32.const 0))))
    (set_local $l1 (tee_local $c1 (i32.load (i32.const 4))))
    (set_local $l2 (tee_local $c2 (i32.load (i32.const 8))))
    (set_local $l3 (tee_local $c3 (i32.load (i32.const 12))))
    (set_local $l4 (tee_local $c4 (i32.load (i32.const 16))))
    (set_local $l5 (tee_local $c5 (i32.load (i32.const 20))))
    (set_local $l6 (tee_local $c6 (i32.load (i32.const 24))))
    (set_local $l7 (tee_local $c7 (i32.load (i32.const 28))))
    (set_local $l8 (tee_local $c8 (i32.load (i32.const 32))))
    (set_local $l9 (tee_local $c9 (i32.load (i32.const 36))))
    (set_local $l10 (tee_local $c10 (i32.load (i32.const 40))))
    (set_local $l11 (tee_local $c11 (i32.load (i32.const 44))))
    (set_local $l12 (tee_local $c12 (i32.load (i32.const 48))))
    (set_local $l13 (tee_local $c13 (i32.load (i32.const 52))))
    (set_local $l14 (tee_local $c14 (i32.load (i32.const 56))))
    (set_local $l15 (tee_local $c15 (i32.load (i32.const 60))))
    ;; bit-muck
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 20)))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 0],x[12]), 7));
          (set_local $l4
            (i32.xor
              (get_local $l4)
              (i32.rotl
                (i32.add
                  (get_local $l0)
                  (get_local $l12))
                (i32.const 7))))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[ 4],x[ 0]), 9));
          (set_local $l8
            (i32.xor
              (get_local $l8)
              (i32.rotl
                (i32.add
                  (get_local $l4)
                  (get_local $l0))
                (i32.const 9))))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[ 8],x[ 4]),13));
          (set_local $l12
            (i32.xor
              (get_local $l12)
              (i32.rotl
                (i32.add
                  (get_local $l8)
                  (get_local $l4))
                (i32.const 13))))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[12],x[ 8]),18));
          (set_local $l0
            (i32.xor
              (get_local $l0)
              (i32.rotl
                (i32.add
                  (get_local $l12)
                  (get_local $l8))
                (i32.const 18))))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 5],x[ 1]), 7));
          (set_local $l9
            (i32.xor
              (get_local $l9)
              (i32.rotl
                (i32.add
                  (get_local $l5)
                  (get_local $l1))
                (i32.const 7))))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[ 9],x[ 5]), 9));
          (set_local $l13
            (i32.xor
              (get_local $l13)
              (i32.rotl
                (i32.add
                  (get_local $l9)
                  (get_local $l5))
                (i32.const 9))))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[13],x[ 9]),13));
          (set_local $l1
            (i32.xor
              (get_local $l1)
              (i32.rotl
                (i32.add
                  (get_local $l13)
                  (get_local $l9))
                (i32.const 13))))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 1],x[13]),18));
          (set_local $l5
            (i32.xor
              (get_local $l5)
              (i32.rotl
                (i32.add
                  (get_local $l1)
                  (get_local $l13))
                (i32.const 18))))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[10],x[ 6]), 7));
          (set_local $l14
            (i32.xor
              (get_local $l14)
              (i32.rotl
                (i32.add
                  (get_local $l10)
                  (get_local $l6))
                (i32.const 7))))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[14],x[10]), 9));
          (set_local $l2
            (i32.xor
              (get_local $l2)
              (i32.rotl
                (i32.add
                  (get_local $l14)
                  (get_local $l10))
                (i32.const 9))))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 2],x[14]),13));
          (set_local $l6
            (i32.xor
              (get_local $l6)
              (i32.rotl
                (i32.add
                  (get_local $l2)
                  (get_local $l14))
                (i32.const 13))))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 6],x[ 2]),18));
          (set_local $l10
            (i32.xor
              (get_local $l10)
              (i32.rotl
                (i32.add
                  (get_local $l6)
                  (get_local $l2))
                (i32.const 18))))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[15],x[11]), 7));
          (set_local $l3
            (i32.xor
              (get_local $l3)
              (i32.rotl
                (i32.add
                  (get_local $l15)
                  (get_local $l11))
                (i32.const 7))))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 3],x[15]), 9));
          (set_local $l7
            (i32.xor
              (get_local $l7)
              (i32.rotl
                (i32.add
                  (get_local $l3)
                  (get_local $l15))
                (i32.const 9))))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[ 7],x[ 3]),13));
          (set_local $l11
            (i32.xor
              (get_local $l11)
              (i32.rotl
                (i32.add
                  (get_local $l7)
                  (get_local $l3))
                (i32.const 13))))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[11],x[ 7]),18));
          (set_local $l15
            (i32.xor
              (get_local $l15)
              (i32.rotl
                (i32.add
                  (get_local $l11)
                  (get_local $l7))
                (i32.const 18))))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[ 0],x[ 3]), 7));
          (set_local $l1
            (i32.xor
              (get_local $l1)
              (i32.rotl
                (i32.add
                  (get_local $l0)
                  (get_local $l3))
                (i32.const 7))))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[ 1],x[ 0]), 9));
          (set_local $l2
            (i32.xor
              (get_local $l2)
              (i32.rotl
                (i32.add
                  (get_local $l1)
                  (get_local $l0))
                (i32.const 9))))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[ 2],x[ 1]),13));
          (set_local $l3
            (i32.xor
              (get_local $l3)
              (i32.rotl
                (i32.add
                  (get_local $l2)
                  (get_local $l1))
                (i32.const 13))))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[ 3],x[ 2]),18));
          (set_local $l0
            (i32.xor
              (get_local $l0)
              (i32.rotl
                (i32.add
                  (get_local $l3)
                  (get_local $l2))
                (i32.const 18))))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 5],x[ 4]), 7));
          (set_local $l6
            (i32.xor
              (get_local $l6)
              (i32.rotl
                (i32.add
                  (get_local $l5)
                  (get_local $l4))
                (i32.const 7))))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 6],x[ 5]), 9));
          (set_local $l7
            (i32.xor
              (get_local $l7)
              (i32.rotl
                (i32.add
                  (get_local $l6)
                  (get_local $l5))
                (i32.const 9))))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 7],x[ 6]),13));
          (set_local $l4
            (i32.xor
              (get_local $l4)
              (i32.rotl
                (i32.add
                  (get_local $l7)
                  (get_local $l6))
                (i32.const 13))))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 4],x[ 7]),18));
          (set_local $l5
            (i32.xor
              (get_local $l5)
              (i32.rotl
                (i32.add
                  (get_local $l4)
                  (get_local $l7))
                (i32.const 18))))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[10],x[ 9]), 7));
          (set_local $l11
            (i32.xor
              (get_local $l11)
              (i32.rotl
                (i32.add
                  (get_local $l10)
                  (get_local $l9))
                (i32.const 7))))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[11],x[10]), 9));
          (set_local $l8
            (i32.xor
              (get_local $l8)
              (i32.rotl
                (i32.add
                  (get_local $l11)
                  (get_local $l10))
                (i32.const 9))))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 8],x[11]),13));
          (set_local $l9
            (i32.xor
              (get_local $l9)
              (i32.rotl
                (i32.add
                  (get_local $l8)
                  (get_local $l11))
                (i32.const 13))))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 9],x[ 8]),18));
          (set_local $l10
            (i32.xor
              (get_local $l10)
              (i32.rotl
                (i32.add
                  (get_local $l9)
                  (get_local $l8))
                (i32.const 18))))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[15],x[14]), 7));
          (set_local $l12
            (i32.xor
              (get_local $l12)
              (i32.rotl
                (i32.add
                  (get_local $l15)
                  (get_local $l14))
                (i32.const 7))))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[12],x[15]), 9));
          (set_local $l13
            (i32.xor
              (get_local $l13)
              (i32.rotl
                (i32.add
                  (get_local $l12)
                  (get_local $l15))
                (i32.const 9))))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[13],x[12]),13));
          (set_local $l14
            (i32.xor
              (get_local $l14)
              (i32.rotl
                (i32.add
                  (get_local $l13)
                  (get_local $l12))
                (i32.const 13))))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[14],x[13]),18));
          (set_local $l15
            (i32.xor
              (get_local $l15)
              (i32.rotl
                (i32.add
                  (get_local $l14)
                  (get_local $l13))
                (i32.const 18))))
          ;; update loop counter
          (set_local $i (i32.add (get_local $i) (i32.const 2)))
          (br 0)
        )
      )
    ;; further modify x by adding input vals by index
    (i32.store (i32.const 64) (i32.add (get_local $l0) (get_local $c0)))
    (i32.store (i32.const 68) (i32.add (get_local $l1) (get_local $c1)))
    (i32.store (i32.const 72) (i32.add (get_local $l2) (get_local $c2)))
    (i32.store (i32.const 76) (i32.add (get_local $l3) (get_local $c3)))
    (i32.store (i32.const 80) (i32.add (get_local $l4) (get_local $c4)))
    (i32.store (i32.const 84) (i32.add (get_local $l5) (get_local $c5)))
    (i32.store (i32.const 88) (i32.add (get_local $l6) (get_local $c6)))
    (i32.store (i32.const 92) (i32.add (get_local $l7) (get_local $c7)))
    (i32.store (i32.const 96) (i32.add (get_local $l8) (get_local $c8)))
    (i32.store (i32.const 100) (i32.add (get_local $l9) (get_local $c9)))
    (i32.store (i32.const 104) (i32.add (get_local $l10) (get_local $c10)))
    (i32.store (i32.const 108) (i32.add (get_local $l11) (get_local $c11)))
    (i32.store (i32.const 112) (i32.add (get_local $l12) (get_local $c12)))
    (i32.store (i32.const 116) (i32.add (get_local $l13) (get_local $c13)))
    (i32.store (i32.const 120) (i32.add (get_local $l14) (get_local $c14)))
    (i32.store (i32.const 124) (i32.add (get_local $l15) (get_local $c15))))

  ;; 256-bit key
  (func (export "keysetup") untrusted (param $1 i32) (param $2 i32) (param $3 i32) (param $4 i32) 
      (param $11 i32) (param $12 i32) (param $13 i32) (param $14 i32)
    ;; index 0
    (i32.store (i32.const 0) (i32.const 0x61707865))
    ;; index 1
    (i32.store (i32.const 4) (get_local $1))
    ;; index 2
    (i32.store (i32.const 8) (get_local $2))
    ;; index 3
    (i32.store (i32.const 12) (get_local $3))
    ;; index 4
    (i32.store (i32.const 16) (get_local $4))
    ;; index 5
    (i32.store (i32.const 20) (i32.const 0x3320646e))
    ;; index 10
    (i32.store (i32.const 40) (i32.const 0x79622d32))
    ;; index 11
    (i32.store (i32.const 44) (get_local $11))
    ;; index 12
    (i32.store (i32.const 48) (get_local $12))
    ;; index 13
    (i32.store (i32.const 52) (get_local $13))
    ;; index 14
    (i32.store (i32.const 56) (get_local $14))
    ;; index 15
    (i32.store (i32.const 60) (i32.const 0x6b206574)))

  ;; 64-bit nonce
  (func (export "noncesetup") untrusted (param $6 i32) (param $7 i32)
    ;; index 6
    (i32.store (i32.const 24) (get_local $6))
    ;; index 7
    (i32.store (i32.const 28) (get_local $7))
    ;; index 8
    (i64.store (i32.const 32) (i64.const 0)))

  ;; encryption scheme
  (func $encrypt (export "encrypt") untrusted (param $bytes i32)
    (local $i i32)
    (local $index i32)
    (local $scratch i32)
    (local $s2 i32)
    ;;(local $pub_scratch i32)
    (local $cptr i32)
    (local $mptr i32)
    (if (i32.ne (get_local $bytes) (i32.const 0))
      (then
        ;; 63936 / 4 = 15984 bytes currently able to encrypt
        (set_local $cptr (i32.const 128))
        (set_local $mptr (i32.add (i32.const 128) (get_local $bytes)))
        (block
          (loop
            (br_if 1 (i32.le_u (get_local $bytes) (i32.const 64)))
              (call $salsa20)
              ;; increment block counter
              (i64.store
                (i32.const 32)
                (i64.add
                  (i64.const 1)
                  (i64.load (i32.const 32))))
              (set_local $i (i32.const 0))
              (block
                (loop
                  (br_if 1 (i32.ge_u (get_local $i) (get_local $bytes)))
                    ;; c[i] = m[i] ^ output[i]
                    (i32.store
                      (i32.add
                        (get_local $cptr)
                        (get_local $i))
                      (i32.xor
                        (i32.load
                          (i32.add
                            (i32.const 64)
                            (get_local $i)))
                        (i32.load
                          (i32.add
                            (get_local $mptr)
                            (get_local $i)))))
                    (set_local $i (i32.add (get_local $i) (i32.const 4)))
                    (br 0)
                  )
                )
              ;; update byte counter
              (set_local $bytes (i32.sub (get_local $bytes) (i32.const 64)))
              ;; c += 64
              (set_local $cptr (i32.add (get_local $cptr) (i32.const 64)))
              ;; m += 64
              (set_local $mptr (i32.add (get_local $mptr) (i32.const 64)))
              (br 0)
            )
          )
        (call $salsa20)
        ;; increment block counter
        (i64.store
          (i32.const 32)
          (i64.add
            (i64.const 1)
            (i64.load (i32.const 32))))
        (set_local $i (i32.const 0))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (get_local $bytes)))
              ;; c[i] = m[i] ^ output[i]
              (i32.store8
                (i32.add
                  (get_local $cptr)
                  (get_local $i))
                (tee_local $scratch
                (i32.xor
                  (i32.load8_u
                    (i32.add
                      (i32.const 64)
                      (get_local $i)))
                  (tee_local $s2
                  (i32.load8_u
                    (i32.add
                      (get_local $mptr)
                      (get_local $i)))))))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br 0)
            )
          )
        )
      )
    )

  (func (export "encrypt_many") untrusted (param $rounds i32) (param $bytes i32)
    (local $i i32)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $rounds)))
          ;; reset index 8 for multiple rounds
          (i64.store (i32.const 32) (i64.const 0))
          (get_local $bytes)
          (call $encrypt)
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0))))

  (func (export "sm") untrusted (param $rounds i32)
    (local $i i32)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $rounds)))
          (call $salsa20)
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0))))

  (func (export "decrypt") untrusted (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))

  (func (export "keystream") untrusted (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))
)
