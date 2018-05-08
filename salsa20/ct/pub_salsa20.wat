(module
  (func $ss20 (import "sec" "ss20"))
  (func $write_sec (import "sec" "write_sec") (param i32) (param s32))
  (func $read_sec (import "sec" "read_sec") (param i32) (result s32))
  (memory 1)
  
  ;; public part of the alg
  (func $salsa20 trusted
    (local $i i32)
    (local $inval i32)
    (local $secval s32)
    (local $secout s32)
    (local $output i32)

    ;; init 'const u32 input[16]' --- (offset 0 - 63)
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
	  (i32.store (get_local $i) (i32.const 8888))
	  (set_local $i (i32.add (get_local $i) (i32.const 4)))
	  (br 0)
	)
      )

    ;; send input to secret module
    (set_local $i (i32.const 0))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 64)))
	  (set_local $inval (i32.load (get_local $i)))
	  (set_local $secval (s32.classify (get_local $inval)))
	  (call $write_sec (get_local $i) (get_local $secval))
	  (set_local $i (i32.add (get_local $i) (i32.const 4)))
	  (br 0)
	)
      )
    
    ;; start encryption
    (call $ss20)
    
    ;; do some declassifying thing to read from the secret memory in other module
    (set_local $i (i32.const 64))
    (block
      (loop
        (br_if 1 (i32.ge_u (get_local $i) (i32.const 128)))
	  (set_local $secout (call $read_sec (get_local $i)))
	  (set_local $output (i32.declassify (get_local $secout)))
	  (i32.store (get_local $i) (get_local $output))
          (set_local $i (i32.add (get_local $i) (i32.const 4)))
          (br 0)
        )
      )
    )

  ;; helper func for testing
  (func $read (param i32) (result i32)
    (i32.load (get_local 0))
    )

  (export "salsa20" (func $salsa20))
  (export "read" (func $read))
)
