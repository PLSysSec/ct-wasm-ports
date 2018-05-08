(input $sha256 "sha256.wat")

;; test init correctness
(assert_return (invoke $sha256 "init"))
(assert_return (invoke $sha256 "read32" (i32.const 0)) (i32.const 0))
(assert_return (invoke $sha256 "read64" (i32.const 4)) (i64.const 0))
(assert_return (invoke $sha256 "read32" (i32.const 12)) (i32.const 0x6a09e667))
(assert_return (invoke $sha256 "read32" (i32.const 16)) (i32.const 0xbb67ae85))
(assert_return (invoke $sha256 "read32" (i32.const 20)) (i32.const 0x3c6ef372))
(assert_return (invoke $sha256 "read32" (i32.const 24)) (i32.const 0xa54ff53a))
(assert_return (invoke $sha256 "read32" (i32.const 28)) (i32.const 0x510e527f))
(assert_return (invoke $sha256 "read32" (i32.const 32)) (i32.const 0x9b05688c))
(assert_return (invoke $sha256 "read32" (i32.const 36)) (i32.const 0x1f83d9ab))
(assert_return (invoke $sha256 "read32" (i32.const 40)) (i32.const 0x5be0cd19))
