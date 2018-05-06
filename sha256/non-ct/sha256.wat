(module
  (memory 1)

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
