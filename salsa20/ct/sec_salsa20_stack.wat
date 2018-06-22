(module
  (import "js" "memory" (memory secret 2))
  
  ;; rounds function
  (func $salsa20
    (local $i i32)
    (local $l0 s32)
    (local $l1 s32)
    (local $l2 s32)
    (local $l3 s32)
    (local $l4 s32)
    (local $l5 s32)
    (local $l6 s32)
    (local $l7 s32)
    (local $l8 s32)
    (local $l9 s32)
    (local $l10 s32)
    (local $l11 s32)
    (local $l12 s32)
    (local $l13 s32)
    (local $l14 s32)
    (local $l15 s32)
    (local $c0 s32)
    (local $c1 s32)
    (local $c2 s32)
    (local $c3 s32)
    (local $c4 s32)
    (local $c5 s32)
    (local $c6 s32)
    (local $c7 s32)
    (local $c8 s32)
    (local $c9 s32)
    (local $c10 s32)
    (local $c11 s32)
    (local $c12 s32)
    (local $c13 s32)
    (local $c14 s32)
    (local $c15 s32)
    ;; init local 'u32 x[16]' --- (offset 16 - 31)
    (set_local $l0 (s32.load (i32.const 0)))
    (set_local $l1 (s32.load (i32.const 4)))
    (set_local $l2 (s32.load (i32.const 8)))
    (set_local $l3 (s32.load (i32.const 12)))
    (set_local $l4 (s32.load (i32.const 16)))
    (set_local $l5 (s32.load (i32.const 20)))
    (set_local $l6 (s32.load (i32.const 24)))
    (set_local $l7 (s32.load (i32.const 28)))
    (set_local $l8 (s32.load (i32.const 32)))
    (set_local $l9 (s32.load (i32.const 36)))
    (set_local $l10 (s32.load (i32.const 40)))
    (set_local $l11 (s32.load (i32.const 44)))
    (set_local $l12 (s32.load (i32.const 48)))
    (set_local $l13 (s32.load (i32.const 52)))
    (set_local $l14 (s32.load (i32.const 56)))
    (set_local $l15 (s32.load (i32.const 60)))
    ;; make local copies for later addition
    (set_local $c0 (get_local $l0))
    (set_local $c1 (get_local $l1))
    (set_local $c2 (get_local $l2))
    (set_local $c3 (get_local $l3))
    (set_local $c4 (get_local $l4))
    (set_local $c5 (get_local $l5))
    (set_local $c6 (get_local $l6))
    (set_local $c7 (get_local $l7))
    (set_local $c8 (get_local $l8))
    (set_local $c9 (get_local $l9))
    (set_local $c10 (get_local $l10))
    (set_local $c11 (get_local $l11))
    (set_local $c12 (get_local $l12))
    (set_local $c13 (get_local $l13))
    (set_local $c14 (get_local $l14))
    (set_local $c15 (get_local $l15))
    ;; bit-muck
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 10)))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 0],x[12]), 7));
	  (set_local $l4
	    (s32.xor
	      (get_local $l4)
	      (s32.rotl
	        (s32.add
		  (get_local $l0)
		  (get_local $l12))
		(s32.const 7))))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[ 4],x[ 0]), 9));
	  (set_local $l8
	    (s32.xor
	      (get_local $l8)
	      (s32.rotl
	        (s32.add
		  (get_local $l4)
		  (get_local $l0))
		(s32.const 9))))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[ 8],x[ 4]),13));
	  (set_local $l12
	    (s32.xor
	      (get_local $l12)
	      (s32.rotl
	        (s32.add
		  (get_local $l8)
		  (get_local $l4))
		(s32.const 13))))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[12],x[ 8]),18));
	  (set_local $l0
	    (s32.xor
	      (get_local $l0)
	      (s32.rotl
	        (s32.add
		  (get_local $l12)
		  (get_local $l8))
		(s32.const 18))))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 5],x[ 1]), 7));
	  (set_local $l9
	    (s32.xor
	      (get_local $l9)
	      (s32.rotl
	        (s32.add
		  (get_local $l5)
		  (get_local $l1))
		(s32.const 7))))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[ 9],x[ 5]), 9));
	  (set_local $l13
	    (s32.xor
	      (get_local $l13)
	      (s32.rotl
	        (s32.add
		  (get_local $l9)
		  (get_local $l5))
		(s32.const 9))))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[13],x[ 9]),13));
	  (set_local $l1
	    (s32.xor
	      (get_local $l1)
	      (s32.rotl
	        (s32.add
		  (get_local $l13)
		  (get_local $l9))
		(s32.const 13))))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 1],x[13]),18));
	  (set_local $l5
	    (s32.xor
	      (get_local $l5)
	      (s32.rotl
	        (s32.add
		  (get_local $l1)
		  (get_local $l13))
		(s32.const 18))))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[10],x[ 6]), 7));
	  (set_local $l14
	    (s32.xor
	      (get_local $l14)
	      (s32.rotl
	        (s32.add
		  (get_local $l10)
		  (get_local $l6))
		(s32.const 7))))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[14],x[10]), 9));
	  (set_local $l2
	    (s32.xor
	      (get_local $l2)
	      (s32.rotl
	        (s32.add
		  (get_local $l14)
		  (get_local $l10))
		(s32.const 9))))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 2],x[14]),13));
	  (set_local $l6
	    (s32.xor
	      (get_local $l6)
	      (s32.rotl
	        (s32.add
		  (get_local $l2)
		  (get_local $l14))
		(s32.const 13))))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 6],x[ 2]),18));
	  (set_local $l10
	    (s32.xor
	      (get_local $l10)
	      (s32.rotl
	        (s32.add
		  (get_local $l6)
		  (get_local $l2))
		(s32.const 18))))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[15],x[11]), 7));
	  (set_local $l3
	    (s32.xor
	      (get_local $l3)
	      (s32.rotl
	        (s32.add
		  (get_local $l15)
		  (get_local $l11))
		(s32.const 7))))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 3],x[15]), 9));
	  (set_local $l7
	    (s32.xor
	      (get_local $l7)
	      (s32.rotl
	        (s32.add
		  (get_local $l3)
		  (get_local $l15))
		(s32.const 9))))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[ 7],x[ 3]),13));
	  (set_local $l11
	    (s32.xor
	      (get_local $l11)
	      (s32.rotl
	        (s32.add
		  (get_local $l7)
		  (get_local $l3))
		(s32.const 13))))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[11],x[ 7]),18));
	  (set_local $l15
	    (s32.xor
	      (get_local $l15)
	      (s32.rotl
	        (s32.add
		  (get_local $l11)
		  (get_local $l7))
		(s32.const 18))))
          ;; x[ 1] = XOR(x[ 1],ROTATE(PLUS(x[ 0],x[ 3]), 7));
	  (set_local $l1
	    (s32.xor
	      (get_local $l1)
	      (s32.rotl
	        (s32.add
		  (get_local $l0)
		  (get_local $l3))
		(s32.const 7))))
          ;; x[ 2] = XOR(x[ 2],ROTATE(PLUS(x[ 1],x[ 0]), 9));
	  (set_local $l2
	    (s32.xor
	      (get_local $l2)
	      (s32.rotl
	        (s32.add
		  (get_local $l1)
		  (get_local $l0))
		(s32.const 9))))
          ;; x[ 3] = XOR(x[ 3],ROTATE(PLUS(x[ 2],x[ 1]),13));
	  (set_local $l3
	    (s32.xor
	      (get_local $l3)
	      (s32.rotl
	        (s32.add
		  (get_local $l2)
		  (get_local $l1))
		(s32.const 13))))
          ;; x[ 0] = XOR(x[ 0],ROTATE(PLUS(x[ 3],x[ 2]),18));
	  (set_local $l0
	    (s32.xor
	      (get_local $l0)
	      (s32.rotl
	        (s32.add
		  (get_local $l3)
		  (get_local $l2))
		(s32.const 18))))
          ;; x[ 6] = XOR(x[ 6],ROTATE(PLUS(x[ 5],x[ 4]), 7));
	  (set_local $l6
	    (s32.xor
	      (get_local $l6)
	      (s32.rotl
	        (s32.add
		  (get_local $l5)
		  (get_local $l4))
		(s32.const 7))))
          ;; x[ 7] = XOR(x[ 7],ROTATE(PLUS(x[ 6],x[ 5]), 9));
	  (set_local $l7
	    (s32.xor
	      (get_local $l7)
	      (s32.rotl
	        (s32.add
		  (get_local $l6)
		  (get_local $l5))
		(s32.const 9))))
          ;; x[ 4] = XOR(x[ 4],ROTATE(PLUS(x[ 7],x[ 6]),13));
	  (set_local $l4
	    (s32.xor
	      (get_local $l4)
	      (s32.rotl
	        (s32.add
		  (get_local $l7)
		  (get_local $l6))
		(s32.const 13))))
          ;; x[ 5] = XOR(x[ 5],ROTATE(PLUS(x[ 4],x[ 7]),18));
	  (set_local $l5
	    (s32.xor
	      (get_local $l5)
	      (s32.rotl
	        (s32.add
		  (get_local $l4)
		  (get_local $l7))
		(s32.const 18))))
          ;; x[11] = XOR(x[11],ROTATE(PLUS(x[10],x[ 9]), 7));
	  (set_local $l11
	    (s32.xor
	      (get_local $l11)
	      (s32.rotl
	        (s32.add
		  (get_local $l10)
		  (get_local $l9))
		(s32.const 7))))
          ;; x[ 8] = XOR(x[ 8],ROTATE(PLUS(x[11],x[10]), 9));
	  (set_local $l8
	    (s32.xor
	      (get_local $l8)
	      (s32.rotl
	        (s32.add
		  (get_local $l11)
		  (get_local $l10))
		(s32.const 9))))
          ;; x[ 9] = XOR(x[ 9],ROTATE(PLUS(x[ 8],x[11]),13));
	  (set_local $l9
	    (s32.xor
	      (get_local $l9)
	      (s32.rotl
	        (s32.add
		  (get_local $l8)
		  (get_local $l11))
		(s32.const 13))))
          ;; x[10] = XOR(x[10],ROTATE(PLUS(x[ 9],x[ 8]),18));
	  (set_local $l10
	    (s32.xor
	      (get_local $l10)
	      (s32.rotl
	        (s32.add
		  (get_local $l9)
		  (get_local $l8))
		(s32.const 18))))
          ;; x[12] = XOR(x[12],ROTATE(PLUS(x[15],x[14]), 7));
	  (set_local $l12
	    (s32.xor
	      (get_local $l12)
	      (s32.rotl
	        (s32.add
		  (get_local $l15)
		  (get_local $l14))
		(s32.const 7))))
          ;; x[13] = XOR(x[13],ROTATE(PLUS(x[12],x[15]), 9));
	  (set_local $l13
	    (s32.xor
	      (get_local $l13)
	      (s32.rotl
	        (s32.add
		  (get_local $l12)
		  (get_local $l15))
		(s32.const 9))))
          ;; x[14] = XOR(x[14],ROTATE(PLUS(x[13],x[12]),13));
	  (set_local $l14
	    (s32.xor
	      (get_local $l14)
	      (s32.rotl
	        (s32.add
		  (get_local $l13)
		  (get_local $l12))
		(s32.const 13))))
          ;; x[15] = XOR(x[15],ROTATE(PLUS(x[14],x[13]),18));
	  (set_local $l15
	    (s32.xor
	      (get_local $l15)
	      (s32.rotl
	        (s32.add
		  (get_local $l14)
		  (get_local $l13))
		(s32.const 18))))
          ;; update loop counter
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0)
        )
      )
    ;; further modify x by adding input vals by index
    (s32.store (i32.const 64) (s32.add (get_local $l0) (get_local $c0)))
    (s32.store (i32.const 68) (s32.add (get_local $l1) (get_local $c1)))
    (s32.store (i32.const 72) (s32.add (get_local $l2) (get_local $c2)))
    (s32.store (i32.const 76) (s32.add (get_local $l3) (get_local $c3)))
    (s32.store (i32.const 80) (s32.add (get_local $l4) (get_local $c4)))
    (s32.store (i32.const 84) (s32.add (get_local $l5) (get_local $c5)))
    (s32.store (i32.const 88) (s32.add (get_local $l6) (get_local $c6)))
    (s32.store (i32.const 92) (s32.add (get_local $l7) (get_local $c7)))
    (s32.store (i32.const 96) (s32.add (get_local $l8) (get_local $c8)))
    (s32.store (i32.const 100) (s32.add (get_local $l9) (get_local $c9)))
    (s32.store (i32.const 104) (s32.add (get_local $l10) (get_local $c10)))
    (s32.store (i32.const 108) (s32.add (get_local $l11) (get_local $c11)))
    (s32.store (i32.const 112) (s32.add (get_local $l12) (get_local $c12)))
    (s32.store (i32.const 116) (s32.add (get_local $l13) (get_local $c13)))
    (s32.store (i32.const 120) (s32.add (get_local $l14) (get_local $c14)))
    (s32.store (i32.const 124) (s32.add (get_local $l15) (get_local $c15))))

  ;; 256-bit key
  (func (export "keysetup") (param $1 s32) (param $2 s32) (param $3 s32) (param $4 s32) 
      (param $11 s32) (param $12 s32) (param $13 s32) (param $14 s32)
    ;; index 0
    (s32.store (i32.const 0) (s32.classify (i32.const 0x61707865)))
    ;; index 1
    (s32.store (i32.const 4) (get_local $1))
    ;; index 2
    (s32.store (i32.const 8) (get_local $2))
    ;; index 3
    (s32.store (i32.const 12) (get_local $3))
    ;; index 4
    (s32.store (i32.const 16) (get_local $4))
    ;; index 5
    (s32.store (i32.const 20) (s32.classify (i32.const 0x3320646e)))
    ;; index 10
    (s32.store (i32.const 40) (s32.classify (i32.const 0x79622d32)))
    ;; index 11
    (s32.store (i32.const 44) (get_local $11))
    ;; index 12
    (s32.store (i32.const 48) (get_local $12))
    ;; index 13
    (s32.store (i32.const 52) (get_local $13))
    ;; index 14
    (s32.store (i32.const 56) (get_local $14))
    ;; index 15
    (s32.store (i32.const 60) (s32.classify (i32.const 0x6b206574))))

  ;; 64-bit nonce
  (func (export "noncesetup") (param $6 i32) (param $7 i32)
    ;; index 6
    (s32.store (i32.const 24) (s32.classify (get_local $6)))
    ;; index 7
    (s32.store (i32.const 28) (s32.classify (get_local $7)))
    ;; index 8
    (s64.store (i32.const 32) (s64.classify (i64.const 0))))

  ;; encryption scheme
  (func $encrypt (export "encrypt") (param $bytes i32)
    (local $i i32)
    (local $index i32)
    (local $scratch s32)
    (local $s2 s32)
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
	      (s64.store
	        (i32.const 32)
		(s64.add
		  (s64.const 1)
		  (s64.load (i32.const 32))))
              (set_local $i (i32.const 0))
              (block
                (loop
                  (br_if 1 (i32.ge_u (get_local $i) (get_local $bytes)))
                    ;; c[i] = m[i] ^ output[i]
                    (s32.store
                      (i32.add
                        (get_local $cptr)
                        (get_local $i))
                      (s32.xor
                        (s32.load
                          (i32.add
                            (i32.const 64)
                            (get_local $i)))
                        (s32.load
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
	(s64.store
	  (i32.const 32)
	  (s64.add
	    (s64.const 1)
	    (s64.load (i32.const 32))))
        (set_local $i (i32.const 0))
	(block
          (loop
            (br_if 1 (i32.ge_u (get_local $i) (get_local $bytes)))
              ;; c[i] = m[i] ^ output[i]
              (s32.store
                (i32.add
                  (get_local $cptr)
                  (get_local $i))
		(tee_local $scratch
                (s32.xor
                  (s32.load
                    (i32.add
                      (i32.const 64)
                      (get_local $i)))
		  (tee_local $s2
                  (s32.load
                    (i32.add
                      (get_local $mptr)
                      (get_local $i)))))))
	      (s32.store (i32.const 0) (get_local $scratch))
	      (s32.store16 (i32.const 4) (get_local $s2))
              (set_local $i (i32.add (get_local $i) (i32.const 4)))
              (br 0)
            )
	  )
        ;; handle byte values that are not a multiple of 4
        ;;(if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 1))
        ;;  ;; if (bytes % 4 == 1) ((val << 24) >> 24)
        ;;  (then
	;;    (set_local $index 
	;;      (i32.add 
	;;        (get_local $cptr) 
	;;	(i32.sub 
	;;	  (get_local $bytes)
	;;	  (i32.const 1))))
	;;    (s32.store (i32.const 0) (s32.classify (get_local $index)))
	;;    (s32.store 
	;;      (get_local $index) 
	;;      (s32.load (get_local $index))))
	;;    ;;  (s32.load8_u 
	;;    ;;    (get_local $index))))
        ;;  (else
        ;;    (if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 2))
        ;;      ;; if (bytes % 4 == 2) ((val << 16) >> 16)
        ;;      (then
	;;        (set_local $index 
	;;	  (i32.add 
	;;	    (get_local $cptr) 
	;;	    (i32.sub 
	;;	      (get_local $bytes) 
	;;	      (i32.const 2))))
	;;	(s32.store 
	;;	  (get_local $index) 
	;;	  (s32.load16_u 
	;;	    (get_local $index))))
        ;;      (else
        ;;        (if (i32.eq (i32.rem_u (get_local $bytes) (i32.const 4)) (i32.const 3))
        ;;          ;; if (bytes % 4 == 3) ((val << 8) >> 8)
        ;;          (then
	;;            (set_local $index 
	;;	      (i32.add 
	;;	        (get_local $cptr) 
	;;		(i32.sub 
	;;		  (get_local $bytes) 
	;;		  (i32.const 3))))
	;;	    ;;(s32.store
	;;	    ;;  (get_local $index)
	;;	    ;;  (s32.load8_u offset=2
	;;	    ;;    (get_local $index))))))))))))
	;;	    ;;(s32.store8 (get_local $index) (s32.const 0))
        ;;            (set_local $scratch 
	;;	      (s32.load 
	;;	        (get_local $index)))
        ;;            (set_local $scratch 
	;;	      (s32.shl 
	;;	        (get_local $scratch) 
	;;	        (s32.const 8)))
        ;;            (set_local $scratch 
	;;	      (s32.shr_u 
	;;	        (get_local $scratch) 
	;;	        (s32.const 8)))
        ;;            (s32.store 
	;;	      (get_local $index)
	;;	      (get_local $scratch)))
        ;;          )
        ;;        )
        ;;      )
        ;;    )
        ;;  )
        )
      )
    )

  (func (export "encrypt_many") (param $rounds i32) (param $bytes i32)
    (local $i i32)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $rounds)))
          ;; reset index 8 for multiple rounds
          (s64.store (i32.const 32) (s64.classify (i64.const 0)))
          (get_local $bytes)
          (call $encrypt)
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0))))

  (func (export "sm") (param $rounds i32)
    (local $i i32)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (get_local $rounds)))
          (call $salsa20)
          (set_local $i (i32.add (get_local $i) (i32.const 1)))
          (br 0))))

  (func (export "decrypt") (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))

  (func (export "keystream") (param $bytes i32)
    (get_local $bytes)
    (call $encrypt))
)
