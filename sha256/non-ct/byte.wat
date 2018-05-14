(module
  (memory (export "memory") 1)
  ;; mem[0..3] datalen, mem[4..11] bitlen, mem[12..43] state
  ;; mem[44..299] m, mem[300..363] data, mem[364..619] k
  ;; mem[620..651] hash (output), mem[652..] input

  (func $readByte (param $x i32) (result i32)
    (return (i32.and (i32.load (get_local $x)) (i32.const 0x000000ff)))
  )

  (func $writeByte (param $x i32) (param $v i32)
    (i32.store
      (get_local $x)
      (i32.or
        (i32.and (i32.load (get_local $x)) (i32.const 0xffffff00))
        (i32.and (get_local $v) (i32.const 0x000000ff))
      )
    )
  )

  (export "readByte" (func $readByte))
  (export "writeByte" (func $writeByte))
)
