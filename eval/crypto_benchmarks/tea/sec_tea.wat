(module
  (import "js" "memory" (memory secret 1))
  (func (export "encrypt") untrusted
    ;; message:
    (local $v0 s32)
    (local $v1 s32)
    ;; key:
    (local $k0 s32)
    (local $k1 s32)
    (local $k2 s32)
    (local $k3 s32)

    ;; local variables
    (local $delta s32)
    (local $sum s32)
    (local $i i32)

    ;; init
    (set_local $delta (s32.const 0x9e3779b9))
    (set_local $sum (s32.const 0))

    ;; load message and key
    (set_local $v0 (s32.load (i32.const 0)))
    (set_local $v1 (s32.load (i32.const 4)))
    (set_local $k0 (s32.load (i32.const 8)))
    (set_local $k1 (s32.load (i32.const 12)))
    (set_local $k2 (s32.load (i32.const 16)))
    (set_local $k3 (s32.load (i32.const 20)))

    ;; loop starts
    (set_local $i (i32.const 0))
    (loop $cycle
      ;; loop body:
      ;; sum += delta;
      (set_local $sum (s32.add (get_local $sum) (get_local $delta)))
      ;; v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
      (set_local $v0
         (s32.add (get_local $v0)
                  (s32.xor (s32.xor (s32.add (s32.shl (get_local $v1) (s32.const 4)) (get_local $k0))
                                    (s32.add (get_local $v1) (get_local $sum)))
                           (s32.add (s32.shr_u (get_local $v1) (s32.const 5)) (get_local $k1))
               )))
      ;; v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
      (set_local $v1
         (s32.add (get_local $v1)
                  (s32.xor (s32.xor (s32.add (s32.shl (get_local $v0) (s32.const 4)) (get_local $k2))
                                    (s32.add (get_local $v0) (get_local $sum)))
                           (s32.add (s32.shr_u (get_local $v0) (s32.const 5)) (get_local $k3))
               )))
      ;; loop condition:
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br_if $cycle (i32.lt_u (get_local $i) (i32.const 32)))
    )
    (s32.store (i32.const 0) (get_local $v0))
    (s32.store (i32.const 4) (get_local $v1))
  )

  (func (export "decrypt") untrusted
    ;; message:
    (local $v0 s32)
    (local $v1 s32)
    ;; key:
    (local $k0 s32)
    (local $k1 s32)
    (local $k2 s32)
    (local $k3 s32)

    ;; local variables
    (local $delta s32)
    (local $sum s32)
    (local $i i32)

    ;; init
    (set_local $delta (s32.const 0x9e3779b9))
    (set_local $sum (s32.const 0xc6ef3720))

    ;; load message and key
    (set_local $v0 (s32.load (i32.const 0)))
    (set_local $v1 (s32.load (i32.const 4)))
    (set_local $k0 (s32.load (i32.const 8)))
    (set_local $k1 (s32.load (i32.const 12)))
    (set_local $k2 (s32.load (i32.const 16)))
    (set_local $k3 (s32.load (i32.const 20)))

    ;; loop starts
    (set_local $i (i32.const 0))
    (loop $cycle
      ;; loop body:
      ;; v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
      (set_local $v1
         (s32.sub (get_local $v1)
                  (s32.xor (s32.xor (s32.add (s32.shl (get_local $v0) (s32.const 4)) (get_local $k2))
                                    (s32.add (get_local $v0) (get_local $sum)))
                           (s32.add (s32.shr_u (get_local $v0) (s32.const 5)) (get_local $k3))
               )))
      ;; v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
      (set_local $v0
         (s32.sub (get_local $v0)
                  (s32.xor (s32.xor (s32.add (s32.shl (get_local $v1) (s32.const 4)) (get_local $k0))
                                    (s32.add (get_local $v1) (get_local $sum)))
                           (s32.add (s32.shr_u (get_local $v1) (s32.const 5)) (get_local $k1))
               )))
      ;; sum -= delta;
      (set_local $sum (s32.sub (get_local $sum) (get_local $delta)))
      ;; loop condition:
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br_if $cycle (i32.lt_u (get_local $i) (i32.const 32)))
    )
    (s32.store (i32.const 0) (get_local $v0))
    (s32.store (i32.const 4) (get_local $v1))
  )
)
