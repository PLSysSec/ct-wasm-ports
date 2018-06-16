(module
  (import "js" "memory" (memory 1))
  (func (export "add")
        (result i32)
    ;;(i32.add (i32.load (i32.const 0)) (i32.load (i32.const 1)))
    (i32.load (i32.const 1))
  )
)
