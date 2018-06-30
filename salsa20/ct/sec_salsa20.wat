(module
  (import "js" "memory" (memory secret 2))
  
  ;; core part of the alg
  (func $salsa20
    (local $i i32)
    (local $scratch s32)
    (local $in_index i32)
    ;; init local 'u32 x[16]' --- (offset 16 - 31)
    (set_local $i (i32.const 64))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 128)))
          (set_local $in_index (i32.sub (get_local $i) (i32.const 64)))
          (s32.store (get_local $i) (s32.load (get_local $in_index)))
          (set_local $i (i32.add (get_local $i) (i32.const 4)))
          (br 0)
        )
      )
    ;; bit-muck
    (set_local $i (i32.const 0))
    (set_local $scratch (s32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 10)))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 0],x[12]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 64)) (s32.load (i32.const 112))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 80)) (get_local $scratch)))
          (s32.store (i32.const 80) (get_local $scratch))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[ 4],x[ 0]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 80)) (s32.load (i32.const 64))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 96)) (get_local $scratch)))
          (s32.store (i32.const 96) (get_local $scratch))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[ 8],x[ 4]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 96)) (s32.load (i32.const 80))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 112)) (get_local $scratch)))
          (s32.store (i32.const 112) (get_local $scratch))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[12],x[ 8]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 112)) (s32.load (i32.const 96))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 64)) (get_local $scratch)))
          (s32.store (i32.const 64) (get_local $scratch))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 5],x[ 1]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 84)) (s32.load (i32.const 68))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 100)) (get_local $scratch)))
          (s32.store (i32.const 100) (get_local $scratch))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[ 9],x[ 5]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 100)) (s32.load (i32.const 84))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 116)) (get_local $scratch)))
          (s32.store (i32.const 116) (get_local $scratch))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[13],x[ 9]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 116)) (s32.load (i32.const 100))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 68)) (get_local $scratch)))
          (s32.store (i32.const 68) (get_local $scratch))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 1],x[13]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 68)) (s32.load (i32.const 116))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 84)) (get_local $scratch)))
          (s32.store (i32.const 84) (get_local $scratch))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[10],x[ 6]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 104)) (s32.load (i32.const 88))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 120)) (get_local $scratch)))
          (s32.store (i32.const 120) (get_local $scratch))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[14],x[10]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 120)) (s32.load (i32.const 104))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 72)) (get_local $scratch)))
          (s32.store (i32.const 72) (get_local $scratch))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 2],x[14]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 72)) (s32.load (i32.const 120))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 88)) (get_local $scratch)))
          (s32.store (i32.const 88) (get_local $scratch))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 6],x[ 2]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 88)) (s32.load (i32.const 72))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 104)) (get_local $scratch)))
          (s32.store (i32.const 104) (get_local $scratch))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[15],x[11]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 124)) (s32.load (i32.const 108))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 76)) (get_local $scratch)))
          (s32.store (i32.const 76) (get_local $scratch))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 3],x[15]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 76)) (s32.load (i32.const 124))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 92)) (get_local $scratch)))
          (s32.store (i32.const 92) (get_local $scratch))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[ 7],x[ 3]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 92)) (s32.load (i32.const 76))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 108)) (get_local $scratch)))
          (s32.store (i32.const 108) (get_local $scratch))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[11],x[ 7]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 108)) (s32.load (i32.const 92))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 124)) (get_local $scratch)))
          (s32.store (i32.const 124) (get_local $scratch))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[ 0],x[ 3]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 64)) (s32.load (i32.const 76))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 68)) (get_local $scratch)))
          (s32.store (i32.const 68) (get_local $scratch))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[ 1],x[ 0]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 68)) (s32.load (i32.const 64))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 72)) (get_local $scratch)))
          (s32.store (i32.const 72) (get_local $scratch))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[ 2],x[ 1]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 72)) (s32.load (i32.const 68))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 76)) (get_local $scratch)))
          (s32.store (i32.const 76) (get_local $scratch))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[ 3],x[ 2]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 76)) (s32.load (i32.const 72))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 64)) (get_local $scratch)))
          (s32.store (i32.const 64) (get_local $scratch))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 5],x[ 4]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 84)) (s32.load (i32.const 80))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 88)) (get_local $scratch)))
          (s32.store (i32.const 88) (get_local $scratch))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 6],x[ 5]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 88)) (s32.load (i32.const 84))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 92)) (get_local $scratch)))
          (s32.store (i32.const 92) (get_local $scratch))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 7],x[ 6]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 92)) (s32.load (i32.const 88))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 80)) (get_local $scratch)))
          (s32.store (i32.const 80) (get_local $scratch))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 4],x[ 7]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 80)) (s32.load (i32.const 92))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 84)) (get_local $scratch)))
          (s32.store (i32.const 84) (get_local $scratch))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[10],x[ 9]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 104)) (s32.load (i32.const 100))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 108)) (get_local $scratch)))
          (s32.store (i32.const 108) (get_local $scratch))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[11],x[10]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 108)) (s32.load (i32.const 104))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 96)) (get_local $scratch)))
          (s32.store (i32.const 96) (get_local $scratch))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 8],x[11]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 96)) (s32.load (i32.const 108))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 100)) (get_local $scratch)))
          (s32.store (i32.const 100) (get_local $scratch))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 9],x[ 8]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 100)) (s32.load (i32.const 96))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 104)) (get_local $scratch)))
          (s32.store (i32.const 104) (get_local $scratch))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[15],x[14]), 7));
          (set_local $scratch (s32.add (s32.load (i32.const 124)) (s32.load (i32.const 120))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 7)))
          (set_local $scratch (s32.xor (s32.load (i32.const 112)) (get_local $scratch)))
          (s32.store (i32.const 112) (get_local $scratch))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[12],x[15]), 9));
          (set_local $scratch (s32.add (s32.load (i32.const 112)) (s32.load (i32.const 124))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 9)))
          (set_local $scratch (s32.xor (s32.load (i32.const 116)) (get_local $scratch)))
          (s32.store (i32.const 116) (get_local $scratch))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[13],x[12]),13));
          (set_local $scratch (s32.add (s32.load (i32.const 116)) (s32.load (i32.const 112))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 13)))
          (set_local $scratch (s32.xor (s32.load (i32.const 120)) (get_local $scratch)))
          (s32.store (i32.const 120) (get_local $scratch))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[14],x[13]),18));
          (set_local $scratch (s32.add (s32.load (i32.const 120)) (s32.load (i32.const 116))))
          (set_local $scratch (s32.rotl (get_local $scratch) (s32.const 18)))
          (set_local $scratch (s32.xor (s32.load (i32.const 124)) (get_local $scratch)))
          (s32.store (i32.const 124) (get_local $scratch))
          ;; update loop counter
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
        )
      )
    ;; further modify x by adding input vals by index
    (set_local $i (i32.const 64))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 128)))
          (set_local $in_index (i32.sub (get_local $i) (i32.const 64)))
          (s32.store (get_local $i) (s32.add (s32.load (get_local $i)) (s32.load (get_local $in_index))))
          (set_local $i (i32.add (get_local $i) (i32.const 4)))
          (br 0)
        )
      )
    )

  ;; 256-bit key
  (func (export "keysetup") untrusted (param $1 i32) (param $2 i32) (param $3 i32) (param $4 i32) 
      (param $11 i32) (param $12 i32) (param $13 i32) (param $14 i32)
    ;; index 0
    (s32.store (i32.const 0) (s32.classify (i32.const 0x61707865)))
    ;; index 1
    (s32.store (i32.const 4) (s32.classify (get_local $1)))
    ;; index 2
    (s32.store (i32.const 8) (s32.classify (get_local $2)))
    ;; index 3
    (s32.store (i32.const 12) (s32.classify (get_local $3)))
    ;; index 4
    (s32.store (i32.const 16) (s32.classify (get_local $4)))
    ;; index 5
    (s32.store (i32.const 20) (s32.classify (i32.const 0x3320646e)))
    ;; index 10
    (s32.store (i32.const 40) (s32.classify (i32.const 0x79622d32)))
    ;; index 11
    (s32.store (i32.const 44) (s32.classify (get_local $11)))
    ;; index 12
    (s32.store (i32.const 48) (s32.classify (get_local $12)))
    ;; index 13
    (s32.store (i32.const 52) (s32.classify (get_local $13)))
    ;; index 14
    (s32.store (i32.const 56) (s32.classify (get_local $14)))
    ;; index 15
    (s32.store (i32.const 60) (s32.classify (i32.const 0x6b206574))))

  ;; 64-bit nonce
  (func (export "noncesetup") untrusted (param $6 i32) (param $7 i32)
    ;; index 6
    (s32.store (i32.const 24) (s32.classify (get_local $6)))
    ;; index 7
    (s32.store (i32.const 28) (s32.classify (get_local $7)))
    ;; index 8
    ;;(s32.store (i32.const 32) (s32.classify (i32.const 0)))
    ;; index 8
    (s64.store (i32.const 32) (s64.classify (i64.const 0))))

  ;; encryption scheme
  (func $encrypt (export "encrypt") untrusted (param $bytes i32)
    (local $i i32)
    (local $index i32)
    (local $scratch s32)
    (local $big_scratch s64)
    (local $pub_scratch i32)
    (local $cptr i32)
    (local $mptr i32)
    (local $outval s32)
    (local $mval s32)
    (if (i32.ne (get_local $bytes) (i32.const 0))
      (then
        ;; 63936 / 4 = 15984 bytes currently able to encrypt
        (set_local $cptr (i32.const 128))
        (set_local $mptr (i32.const 64064))
        (block
          (loop
            (br_if 1 (i32.le_u (get_local $bytes) (i32.const 64)))
              (call $salsa20)
              ;; x->input[8] PLUSONE
              (set_local $big_scratch (s64.load (i32.const 32)))
              (set_local $big_scratch (s64.add (get_local $big_scratch) (s64.const 1)))
              (s64.store (i32.const 32) (get_local $big_scratch))
              ;; XOR
              (set_local $i (i32.const 0))
              (set_local $pub_scratch (i32.mul (i32.const 4) (get_local $bytes)))
              (block
                (loop
                  (br_if 1 (i32.ge_u (get_local $i) (get_local $pub_scratch)))
                    ;; c[i] = m[i] ^ output[i]
                    (set_local $index (i32.add (get_local $i) (i32.const 64)))
                    (set_local $outval (s32.load (get_local $index)))
                    (set_local $index (i32.add (get_local $i) (get_local $mptr)))
                    (set_local $mval (s32.load (get_local $index)))
                    (set_local $index (i32.add (get_local $i) (get_local $cptr)))
                    (s32.store (get_local $index) (s32.xor (get_local $mval) (get_local $outval)))
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
        ;; x->input[8] PLUSONE
        (set_local $big_scratch (s64.load (i32.const 32)))
        (set_local $big_scratch (s64.add (get_local $big_scratch) (s64.const 1)))
        (s64.store (i32.const 32) (get_local $big_scratch))
        ;; XOR
        (set_local $i (i32.const 0))
        (set_local $pub_scratch (i32.mul (i32.const 4) (get_local $bytes)))
        (s32.store (i32.const 12) (s32.classify (get_local $pub_scratch)))
        (block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (get_local $pub_scratch)))
              ;; c[i] = m[i] ^ output[i]
              (set_local $index (i32.add (get_local $i) (i32.const 64)))
              (set_local $outval (s32.load (get_local $index)))
              (set_local $index (i32.add (get_local $i) (get_local $mptr)))
              (set_local $mval (s32.load (get_local $index)))
              (set_local $index (i32.add (get_local $i) (get_local $cptr)))
              (s32.store (get_local $index) (s32.xor (get_local $mval) (get_local $outval)))
              (set_local $i (i32.add (get_local $i) (i32.const 4)))
              (br 0)
            )
          )
        ;; handle byte values that are not a multiple of 4
        (if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 1))
          ;; if (bytes % 4 == 1) ((val << 24) >> 24)
          (then
            (set_local $i (i32.sub (get_local $i) (i32.const 4)))
            (set_local $i (i32.div_u (get_local $i) (i32.const 4)))
            (set_local $index (i32.add (get_local $i) (get_local $cptr)))
            (set_local $scratch (s32.load (get_local $index)))
            (set_local $scratch (s32.shl (get_local $scratch) (s32.const 24)))
            (set_local $scratch (s32.shr_u (get_local $scratch) (s32.const 24)))
            (s32.store (get_local $index) (s32.const 0))
            (s32.store (get_local $index) (get_local $scratch)))
          (else
            (if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 2))
              ;; if (bytes % 4 == 2) ((val << 16) >> 16)
              (then
                (set_local $i (i32.sub (get_local $i) (i32.const 8)))
                (set_local $i (i32.div_u (get_local $i) (i32.const 4)))
                (set_local $index (i32.add (get_local $i) (get_local $cptr)))
                (set_local $scratch (s32.load (get_local $index)))
                (set_local $scratch (s32.shl (get_local $scratch) (s32.const 16)))
                (set_local $scratch (s32.shr_u (get_local $scratch) (s32.const 16)))
                (s32.store (get_local $index) (s32.const 0))
                (s32.store (get_local $index) (get_local $scratch)))
              (else
                (if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 3))
                  ;; if (bytes % 4 == 3) ((val << 8) >> 8)
                  (then
                    (set_local $i (i32.sub (get_local $i) (i32.const 12)))
                    (set_local $i (i32.div_u (get_local $i) (i32.const 4)))
                    (set_local $index (i32.add (get_local $i) (get_local $cptr)))
                    (set_local $scratch (s32.load (get_local $index)))
                    (set_local $scratch (s32.shl (get_local $scratch) (s32.const 8)))
                    (set_local $scratch (s32.shr_u (get_local $scratch) (s32.const 8)))
                    (s32.store (get_local $index) (s32.const 0))
                    (s32.store (get_local $index) (get_local $scratch)))
                  )
                )
              )
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
          (get_local $bytes)
          (call $encrypt)
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0))))

  (func (export "decrypt") untrusted (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))

  (func (export "keystream") untrusted (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))
)
