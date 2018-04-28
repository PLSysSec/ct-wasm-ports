(input $ss "w_sec_salsa20.wat")
(register "w_sec_salsa20")

(input $salsa "w_pub_salsa20.wat")
(register "w_pub_salsa20")

(assert_return (invoke $salsa "salsa20"))

;; check input
;;(assert_return (invoke $salsa "read" (i32.const 0)) (i32.const 8888))
;;(assert_return (invoke $salsa "read" (i32.const 1)) (i32.const 3087007778))
;;(assert_return (invoke $salsa "read" (i32.const 2)) (i32.const 582483968))
;;(assert_return (invoke $salsa "read" (i32.const 3)) (i32.const 2275328))
;;(assert_return (invoke $salsa "read" (i32.const 4)) (i32.const 8888))
;;(assert_return (invoke $salsa "read" (i32.const 5)) (i32.const 3087007778))
;;(assert_return (invoke $salsa "read" (i32.const 6)) (i32.const 582483968))
;;(assert_return (invoke $salsa "read" (i32.const 7)) (i32.const 2275328))

;; check x init correctly
;;(assert_return (invoke $salsa "read" (i32.const 64)) (i32.const 8888))
;;(assert_return (invoke $salsa "read" (i32.const 65)) (i32.const 3087007778))
;;(assert_return (invoke $salsa "read" (i32.const 66)) (i32.const 582483968))
;;(assert_return (invoke $salsa "read" (i32.const 67)) (i32.const 2275328))
;;
;;(assert_return (invoke $salsa "read" (i32.const 128)) (i32.const 0))

;; check 'plus' loop correctness
;;(assert_return (invoke $salsa "read" (i32.const 64)) (i32.const 17776))
;;(assert_return (invoke $salsa "read" (i32.const 65)) (i32.const 1879048261))
;;(assert_return (invoke $salsa "read" (i32.const 66)) (i32.const 1164967936))
;;(assert_return (invoke $salsa "read" (i32.const 67)) (i32.const 4550656))

;; check 'muck' loop correctness
;;(assert_return (invoke $salsa "read" (i32.const 64)) (i32.const 17776))
;;(assert_return (invoke $salsa "read" (i32.const 65)) (i32.const 1879048261))
;;(assert_return (invoke $salsa "read" (i32.const 66)) (i32.const 1164967936))
;;(assert_return (invoke $salsa "read" (i32.const 67)) (i32.const 4550656))
;;(assert_return (invoke $salsa "read" (i32.const 92)) (i32.const 17776))
;;(assert_return (invoke $salsa "read" (i32.const 96)) (i32.const 1173374320))
;;(assert_return (invoke $salsa "read" (i32.const 100)) (i32.const 17776))

;; check final output
(assert_return (invoke $salsa "read" (i32.const 64)) (i32.const 2050581199))
(assert_return (invoke $salsa "read" (i32.const 68)) (i32.const 2146000113))
(assert_return (invoke $salsa "read" (i32.const 72)) (i32.const 3412130372))
(assert_return (invoke $salsa "read" (i32.const 76)) (i32.const 2029613081))
(assert_return (invoke $salsa "read" (i32.const 80)) (i32.const 2029613081))
(assert_return (invoke $salsa "read" (i32.const 84)) (i32.const 2050581199))
(assert_return (invoke $salsa "read" (i32.const 88)) (i32.const 2146000113))
(assert_return (invoke $salsa "read" (i32.const 92)) (i32.const 3412130372))
(assert_return (invoke $salsa "read" (i32.const 96)) (i32.const 3412130372))
(assert_return (invoke $salsa "read" (i32.const 100)) (i32.const 2029613081))
(assert_return (invoke $salsa "read" (i32.const 104)) (i32.const 2050581199))
(assert_return (invoke $salsa "read" (i32.const 108)) (i32.const 2146000113))
(assert_return (invoke $salsa "read" (i32.const 112)) (i32.const 2146000113))
(assert_return (invoke $salsa "read" (i32.const 116)) (i32.const 3412130372))
(assert_return (invoke $salsa "read" (i32.const 120)) (i32.const 2029613081))
(assert_return (invoke $salsa "read" (i32.const 124)) (i32.const 2050581199))
