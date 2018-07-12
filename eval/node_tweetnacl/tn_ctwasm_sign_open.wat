(module (import "js" "mem" (memory 1))
;; Author: Torsten Stüber

;; input/output pointer $h: 64 bytes; 8 x 64 bit numbers (stored little endian, not big endian as in original tweetnacl)
;; input pointer $m: $n bytes
;; input value $n
;; alloc pointer $alloc: 128 bytes
(func $crypto_hashblocks (export "crypto_hashblocks") untrusted
	(param $h i32)
	(param $m i32)
	(param $n i32)
	(param $alloc i32)

	(local $b0 i64) (local $b1 i64) (local $b2 i64) (local $b3 i64)
	(local $b4 i64) (local $b5 i64) (local $b6 i64) (local $b7 i64)
	(local $a0 i64) (local $a1 i64) (local $a2 i64) (local $a3 i64)
	(local $a4 i64) (local $a5 i64) (local $a6 i64) (local $a7 i64)
	(local $t i64)
	(local $tmp1 i64) (local $tmp2 i64) (local $tmp3 i64)
	(local $w i32) (local $i i32) (local $j i32) (local $k i32) (local $K i32)

	(set_local $w (get_local $alloc))
	
	(set_local $a0 (i64.load offset=0 (get_local $h)))
	(set_local $a1 (i64.load offset=8 (get_local $h)))
	(set_local $a2 (i64.load offset=16 (get_local $h)))
	(set_local $a3 (i64.load offset=24 (get_local $h)))
	(set_local $a4 (i64.load offset=32 (get_local $h)))
	(set_local $a5 (i64.load offset=40 (get_local $h)))
	(set_local $a6 (i64.load offset=48 (get_local $h)))
	(set_local $a7 (i64.load offset=56 (get_local $h)))

	(block
		(loop
			(br_if 1(i32.lt_u (get_local $n) (i32.const 128)))

			(set_local $i (i32.const 0))
			(set_local $j (get_local $m))
			(set_local $k (get_local $w))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $i) (i32.const 16)))

					(i64.store (get_local $k) (i64.or
						(i64.or
							(i64.or
								(i64.shl (i64.load8_u offset=0 (get_local $j)) (i64.const 56))
								(i64.shl (i64.load8_u offset=1 (get_local $j)) (i64.const 48))
							)
							(i64.or
								(i64.shl (i64.load8_u offset=2 (get_local $j)) (i64.const 40))
								(i64.shl (i64.load8_u offset=3 (get_local $j)) (i64.const 32))
							)
						)
						(i64.or
							(i64.or
								(i64.shl (i64.load8_u offset=4 (get_local $j)) (i64.const 24))
								(i64.shl (i64.load8_u offset=5 (get_local $j)) (i64.const 16))
							)
							(i64.or 
								(i64.shl (i64.load8_u offset=6 (get_local $j)) (i64.const 8))
								(i64.load8_u offset=7 (get_local $j))
							)
						)
					))

					(set_local $i (i32.add (i32.const 1) (get_local $i)))
					(set_local $j (i32.add (i32.const 8) (get_local $j)))
					(set_local $k (i32.add (i32.const 8) (get_local $k)))
					(br 0)
				)
			)

			(set_local $i (i32.const 0))
			(set_local $K (get_global $K))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $i) (i32.const 80)))

					(set_local $b0 (get_local $a0))
					(set_local $b1 (get_local $a1))
					(set_local $b2 (get_local $a2))
					(set_local $b3 (get_local $a3))
					(set_local $b4 (get_local $a4))
					(set_local $b5 (get_local $a5))
					(set_local $b6 (get_local $a6))
					(set_local $b7 (get_local $a7))

					(set_local $t (i64.add
						(i64.add
							(get_local $a7)
							(i64.xor 
								(i64.xor
									(i64.rotr (get_local $a4) (i64.const 14))
									(i64.rotr (get_local $a4) (i64.const 18))
								)
								(i64.rotr (get_local $a4) (i64.const 41))
							)
						)
						(i64.add
							(i64.xor 
								(i64.and (get_local $a4) (get_local $a5))
								(i64.and (i64.xor (get_local $a4) (i64.const -1)) (get_local $a6))
							)
							(i64.add
								(i64.load (get_local $K))
								(i64.load (i32.add (get_local $w) (i32.shl (i32.and (get_local $i) (i32.const 0xf)) (i32.const 3))))
							)
						)
					))

					(set_local $b7 (i64.add
						(i64.add
							(get_local $t)
							(i64.xor 
								(i64.xor
									(i64.rotr (get_local $a0) (i64.const 28))
									(i64.rotr (get_local $a0) (i64.const 34))
								)
								(i64.rotr (get_local $a0) (i64.const 39))
							)
						)
						(i64.xor 
							(i64.xor
								(i64.and (get_local $a0) (get_local $a1))
								(i64.and (get_local $a0) (get_local $a2))
							)
							(i64.and (get_local $a1) (get_local $a2))
						)
					))

					(set_local $b3 (i64.add (get_local $b3) (get_local $t)))

					(set_local $a1 (get_local $b0))
					(set_local $a2 (get_local $b1))
					(set_local $a3 (get_local $b2))
					(set_local $a4 (get_local $b3))
					(set_local $a5 (get_local $b4))
					(set_local $a6 (get_local $b5))
					(set_local $a7 (get_local $b6))
					(set_local $a0 (get_local $b7))

					(if (i32.eq (i32.and (get_local $i) (i32.const 0xf)) (i32.const 15))
						(then

							(set_local $tmp1 (i64.load offset=72 (get_local $w)))
							(set_local $tmp2 (i64.load offset=8 (get_local $w)))
							(set_local $tmp3 (i64.load offset=112 (get_local $w)))
							(i64.store offset=0 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=0 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=80 (get_local $w)))
							(set_local $tmp2 (i64.load offset=16 (get_local $w)))
							(set_local $tmp3 (i64.load offset=120 (get_local $w)))
							(i64.store offset=8 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=8 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=88 (get_local $w)))
							(set_local $tmp2 (i64.load offset=24 (get_local $w)))
							(set_local $tmp3 (i64.load offset=0 (get_local $w)))
							(i64.store offset=16 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=16 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=96 (get_local $w)))
							(set_local $tmp2 (i64.load offset=32 (get_local $w)))
							(set_local $tmp3 (i64.load offset=8 (get_local $w)))
							(i64.store offset=24 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=24 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=104 (get_local $w)))
							(set_local $tmp2 (i64.load offset=40 (get_local $w)))
							(set_local $tmp3 (i64.load offset=16 (get_local $w)))
							(i64.store offset=32 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=32 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=112 (get_local $w)))
							(set_local $tmp2 (i64.load offset=48 (get_local $w)))
							(set_local $tmp3 (i64.load offset=24 (get_local $w)))
							(i64.store offset=40 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=40 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=120 (get_local $w)))
							(set_local $tmp2 (i64.load offset=56 (get_local $w)))
							(set_local $tmp3 (i64.load offset=32 (get_local $w)))
							(i64.store offset=48 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=48 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=0 (get_local $w)))
							(set_local $tmp2 (i64.load offset=64 (get_local $w)))
							(set_local $tmp3 (i64.load offset=40 (get_local $w)))
							(i64.store offset=56 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=56 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=8 (get_local $w)))
							(set_local $tmp2 (i64.load offset=72 (get_local $w)))
							(set_local $tmp3 (i64.load offset=48 (get_local $w)))
							(i64.store offset=64 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=64 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=16 (get_local $w)))
							(set_local $tmp2 (i64.load offset=80 (get_local $w)))
							(set_local $tmp3 (i64.load offset=56 (get_local $w)))
							(i64.store offset=72 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=72 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=24 (get_local $w)))
							(set_local $tmp2 (i64.load offset=88 (get_local $w)))
							(set_local $tmp3 (i64.load offset=64 (get_local $w)))
							(i64.store offset=80 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=80 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=32 (get_local $w)))
							(set_local $tmp2 (i64.load offset=96 (get_local $w)))
							(set_local $tmp3 (i64.load offset=72 (get_local $w)))
							(i64.store offset=88 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=88 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=40 (get_local $w)))
							(set_local $tmp2 (i64.load offset=104 (get_local $w)))
							(set_local $tmp3 (i64.load offset=80 (get_local $w)))
							(i64.store offset=96 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=96 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=48 (get_local $w)))
							(set_local $tmp2 (i64.load offset=112 (get_local $w)))
							(set_local $tmp3 (i64.load offset=88 (get_local $w)))
							(i64.store offset=104 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=104 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=56 (get_local $w)))
							(set_local $tmp2 (i64.load offset=120 (get_local $w)))
							(set_local $tmp3 (i64.load offset=96 (get_local $w)))
							(i64.store offset=112 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=112 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=64 (get_local $w)))
							(set_local $tmp2 (i64.load offset=0 (get_local $w)))
							(set_local $tmp3 (i64.load offset=104 (get_local $w)))
							(i64.store offset=120 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=120 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							

						)
					)

					(set_local $i (i32.add (i32.const 1) (get_local $i)))
					(set_local $K (i32.add (i32.const 8) (get_local $K)))
					(br 0)
				)
			)

			(i64.store offset=0 (get_local $h) (tee_local $a0 (i64.add
				(get_local $a0) (i64.load offset=0 (get_local $h))
			)))
			(i64.store offset=8 (get_local $h) (tee_local $a1 (i64.add
				(get_local $a1) (i64.load offset=8 (get_local $h))
			)))
			(i64.store offset=16 (get_local $h) (tee_local $a2 (i64.add
				(get_local $a2) (i64.load offset=16 (get_local $h))
			)))
			(i64.store offset=24 (get_local $h) (tee_local $a3 (i64.add
				(get_local $a3) (i64.load offset=24 (get_local $h))
			)))
			(i64.store offset=32 (get_local $h) (tee_local $a4 (i64.add
				(get_local $a4) (i64.load offset=32 (get_local $h))
			)))
			(i64.store offset=40 (get_local $h) (tee_local $a5 (i64.add
				(get_local $a5) (i64.load offset=40 (get_local $h))
			)))
			(i64.store offset=48 (get_local $h) (tee_local $a6 (i64.add
				(get_local $a6) (i64.load offset=48 (get_local $h))
			)))
			(i64.store offset=56 (get_local $h) (tee_local $a7 (i64.add
				(get_local $a7) (i64.load offset=56 (get_local $h))
			)))

			(set_local $m (i32.add (i32.const 128) (get_local $m)))
			(set_local $n (i32.sub (get_local $n) (i32.const 128)))
			(br 0)
		)
	)
)
;; Author: Torsten Stüber

;; output pointer $out: 64 bytes
;; input pointer $m: $n bytes
;; input value $n
;; alloc pointer $alloc: 128 + 256 = 384 bytes
(func $crypto_hash (export "crypto_hash") untrusted
	(param $out i32)
	(param $m i32)
	(param $n i32)
	(param $alloc i32)

	(local $x i32)
	(local $i i32)
	(local $tmp i32)
	(local $a i64)

	(set_local $x (i32.add (i32.const 128) (get_local $alloc)))

	(i64.store offset=0  (get_local $out) (i64.const 0x6a09e667f3bcc908))
	(i64.store offset=8  (get_local $out) (i64.const 0xbb67ae8584caa73b))
	(i64.store offset=16 (get_local $out) (i64.const 0x3c6ef372fe94f82b))
	(i64.store offset=24 (get_local $out) (i64.const 0xa54ff53a5f1d36f1))
	(i64.store offset=32 (get_local $out) (i64.const 0x510e527fade682d1))
	(i64.store offset=40 (get_local $out) (i64.const 0x9b05688c2b3e6c1f))
	(i64.store offset=48 (get_local $out) (i64.const 0x1f83d9abfb41bd6b))
	(i64.store offset=56 (get_local $out) (i64.const 0x5be0cd19137e2179))

	(get_local $out)
	(get_local $m)
	(get_local $n)
	(get_local $alloc)
	(call $crypto_hashblocks)

	(get_local $n)
		(set_local $m (i32.add (get_local $m) (get_local $n)))
		(set_local $n (i32.and (get_local $n) (i32.const 127)))
		(set_local $m (i32.sub (get_local $m) (get_local $n)))

		(set_local $tmp (get_local $x))
		(block
			(loop
				(br_if 1 (i32.eq (get_local $i) (get_local $n)))

				(i32.store8 (get_local $tmp) (i32.load8_u (get_local $m)))

				(set_local $i (i32.add (i32.const 1) (get_local $i)))
				(set_local $tmp (i32.add (i32.const 1) (get_local $tmp)))
				(set_local $m (i32.add (i32.const 1) (get_local $m)))
				(br 0)
			)
		)
	
		(i32.store8 (get_local $tmp) (i32.const 128))
		(set_local $i (i32.add (get_local $i) (i32.const 1)))
		(block
			(loop
				(br_if 1 (i32.eq (get_local $i) (i32.const 256)))

				(i32.store8 offset=1 (get_local $tmp) (i32.const 0))

				(set_local $i (i32.add (i32.const 1) (get_local $i)))
				(set_local $tmp (i32.add (i32.const 1) (get_local $tmp)))
				(br 0)
			)
		)
	(set_local $tmp)

	(set_local $n (select (i32.const 128) (i32.const 256) (i32.lt_u (get_local $n) (i32.const 112))))

	(get_local $out)
	(get_local $x)
	(get_local $n)
	(get_local $alloc)
		(set_local $x (i32.sub (i32.add (get_local $x) (get_local $n)) (i32.const 9)))
		(i32.store8 (get_local $x) (i32.const 0))
		(i32.store8 offset=1 (get_local $x) (i32.const 0))
		(i32.store8 offset=2 (get_local $x) (i32.const 0))
		(i32.store8 offset=3 (get_local $x) (i32.const 0))
		(i32.store8 offset=4 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 29)))
		(i32.store8 offset=5 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 21)))
		(i32.store8 offset=6 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 13)))
		(i32.store8 offset=7 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 5)))
		(i32.store8 offset=8 (get_local $x) (i32.shl (get_local $tmp) (i32.const 3)))
	(call $crypto_hashblocks)

	(set_local $a (i64.load offset=0 (get_local $out)))
	(i64.store8 offset=0 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=1 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=2 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=3 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=4 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=5 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=6 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=7 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=8 (get_local $out)))
	(i64.store8 offset=8 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=9 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=10 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=11 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=12 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=13 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=14 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=15 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=16 (get_local $out)))
	(i64.store8 offset=16 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=17 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=18 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=19 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=20 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=21 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=22 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=23 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=24 (get_local $out)))
	(i64.store8 offset=24 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=25 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=26 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=27 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=28 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=29 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=30 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=31 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=32 (get_local $out)))
	(i64.store8 offset=32 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=33 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=34 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=35 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=36 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=37 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=38 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=39 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=40 (get_local $out)))
	(i64.store8 offset=40 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=41 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=42 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=43 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=44 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=45 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=46 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=47 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=48 (get_local $out)))
	(i64.store8 offset=48 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=49 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=50 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=51 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=52 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=53 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=54 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=55 (get_local $out) (get_local $a))

	(set_local $a (i64.load offset=56 (get_local $out)))
	(i64.store8 offset=56 (get_local $out) (i64.shr_u (get_local $a) (i64.const 56)))
	(i64.store8 offset=57 (get_local $out) (i64.shr_u (get_local $a) (i64.const 48)))
	(i64.store8 offset=58 (get_local $out) (i64.shr_u (get_local $a) (i64.const 40)))
	(i64.store8 offset=59 (get_local $out) (i64.shr_u (get_local $a) (i64.const 32)))
	(i64.store8 offset=60 (get_local $out) (i64.shr_u (get_local $a) (i64.const 24)))
	(i64.store8 offset=61 (get_local $out) (i64.shr_u (get_local $a) (i64.const 16)))
	(i64.store8 offset=62 (get_local $out) (i64.shr_u (get_local $a) (i64.const 8)))
	(i64.store8 offset=63 (get_local $out) (get_local $a))
)
;; Author: Torsten Stüber

;; output pointer $m: $n bytes; must already be a copy of $sm
;; input pointer $sm: $n bytes
;; input value $n
;; input $pk: 32 bytes
;; alloc pointer $alloc: 896 + 32 + 64 + 2 * 512 = 2016 bytes
;; return: -1 if error; $m - 64 otherwise
(func $crypto_sign_open (export "crypto_sign_open") 
	(param $m i32)
	(param $sm i32)
	(param $n i32)
	(param $pk i32)
	(param $alloc i32)
	(result i32)
	
	(local $t i32)
	(local $h i32)
	(local $p i32)
	(local $q i32)
	
	(tee_local $t (i32.add (get_local $alloc) (i32.const 896)))
	(tee_local $h (i32.add (i32.const 32)))
	(tee_local $p (i32.add (i32.const 64)))
	(set_local $q (i32.add (i32.const 512)))
	
	(if (i32.lt_u (get_local $n) (i32.const 64))
		(then
			(i32.const -1)
			(return)
		)
	)

	(if (call $unpackneg (get_local $q) (get_local $pk) (get_local $alloc))
		(then
			(i32.const -1)
			(return)
		)
	)

	(i64.store offset=32 (get_local $m) (i64.load offset=0 (get_local $pk)))
	(i64.store offset=40 (get_local $m) (i64.load offset=8 (get_local $pk)))
	(i64.store offset=48 (get_local $m) (i64.load offset=16 (get_local $pk)))
	(i64.store offset=56 (get_local $m) (i64.load offset=24 (get_local $pk)))

	(get_local $h)
	(get_local $m)
	(get_local $n)
	(get_local $alloc)
	(call $crypto_hash)

	(get_local $h)
	(get_local $alloc)
	(call $reduce)

	(get_local $p)
	(get_local $q)
	(get_local $h)
	(get_local $alloc)
	(call $scalarmult)

	(get_local $q)
	(i32.add (get_local $sm) (i32.const 32))
	(get_local $alloc)
	(call $scalarbase)
	
	(get_local $p)
	(get_local $q)
	(get_local $alloc)
	(call $add)

	(get_local $t)
	(get_local $p)
	(get_local $alloc)
	(call $pack)

	(set_local $n (i32.sub (get_local $n) (i32.const 64)))

	(if (call $crypto_verify_32 (get_local $sm) (get_local $t))
		(then
			(i32.const -1)
			(return)
		)
	)

	(get_local $n)
)
;; Author: Torsten Stüber

;; input pointer $x: $n bytes
;; input pointer $y: $n bytes
;; input value $n
;; return bool
(func $vn (export "vn") untrusted
	(param $x i32)
	(param $y i32)
	(param $n i32)
	(result i32)

	(local $d i64)
	
	(block
		(loop
			(br_if 1 (i32.lt_u (get_local $n) (i32.const 8)))

			(set_local $d (i64.or (get_local $d)
				(i64.xor (i64.load (get_local $x)) (i64.load (get_local $y)))))

			(set_local $n (i32.sub (get_local $n) (i32.const 8)))
			(set_local $x (i32.add (get_local $x) (i32.const 8)))
			(set_local $y (i32.add (get_local $y) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $d (i64.or
		(i64.and (get_local $d) (i64.const 0xffffffff))
		(i64.shr_u (get_local $d) (i64.const 32))
	))

	(block
		(loop
			(br_if 1 (i32.eqz (get_local $n)))

			(set_local $d (i64.or (get_local $d)
				(i64.xor (i64.load8_u (get_local $x)) (i64.load8_u (get_local $y)))))

			(set_local $n (i32.sub (get_local $n) (i32.const 1)))
			(set_local $x (i32.add (get_local $x) (i32.const 1)))
			(set_local $y (i32.add (get_local $y) (i32.const 1)))
			(br 0)
		)
	)

	(i32.wrap/i64 (i64.sub
		(i64.and (i64.const 1) (i64.shr_u (i64.sub (get_local $d) (i64.const 1)) (i64.const 32))) 
		(i64.const 1)))
)

;; input pointer $x: 16 bytes
;; input pointer $y: 16 bytes
;; return bool
(func $crypto_verify_16 (export "crypto_verify_16") untrusted
	(param $x i32)
	(param $y i32)
	(result i32)

	(local $d i64)
	(set_local $d (i64.or
		(i64.xor (i64.load offset=0 (get_local $x)) (i64.load offset=0 (get_local $y)))
		(i64.xor (i64.load offset=8 (get_local $x)) (i64.load offset=8 (get_local $y)))
	))

	(set_local $d (i64.or
		(i64.and (get_local $d) (i64.const 0xffffffff))
		(i64.shr_u (get_local $d) (i64.const 32))
	))

	(i32.wrap/i64 (i64.sub
		(i64.and (i64.const 1) (i64.shr_u (i64.sub (get_local $d) (i64.const 1)) (i64.const 32))) 
		(i64.const 1)))
)

;; input pointer $x: 32 bytes
;; input pointer $y: 32 bytes
;; return bool
(func $crypto_verify_32 (export "crypto_verify_32") untrusted
	(param $x i32)
	(param $y i32)
	(result i32)

	(local $d i64)
	(set_local $d (i64.or
		(i64.or
			(i64.xor (i64.load offset=0 (get_local $x)) (i64.load offset=0 (get_local $y)))
			(i64.xor (i64.load offset=8 (get_local $x)) (i64.load offset=8 (get_local $y)))
		)
		(i64.or
			(i64.xor (i64.load offset=16 (get_local $x)) (i64.load offset=16 (get_local $y)))
			(i64.xor (i64.load offset=24 (get_local $x)) (i64.load offset=24 (get_local $y)))
		)
	))

	(set_local $d (i64.or
		(i64.and (get_local $d) (i64.const 0xffffffff))
		(i64.shr_u (get_local $d) (i64.const 32))
	))

	(i32.wrap/i64 (i64.sub
		(i64.and (i64.const 1) (i64.shr_u (i64.sub (get_local $d) (i64.const 1)) (i64.const 32))) 
		(i64.const 1)))
)
(global $gf0 i32 (i32.const 0x00)) ;; pointer to 128 bytes
(global $_0 i32 (i32.const 0x00)) ;; pointer to 16 bytes

(data (i32.const 0x80) "\01")
(global $gf1 i32 (i32.const 0x80)) ;; pointer to 128 bytes

(data (i32.const 0x100) "\41\db\00\00\00\00\00\00\01")
(global $_121665 i32 (i32.const 0x100)) ;; pointer to 128 bytes

(data (i32.const 0x180) "\a3\78\00\00\00\00\00\00\59\13\00\00\00\00\00\00\ca\4d\00\00\00\00\00\00\eb\75\00\00\00\00\00\00\ab\d8\00\00\00\00\00\00\41\41\00\00\00\00\00\00\4d\0a\00\00\00\00\00\00\70\00\00\00\00\00\00\00\98\e8\00\00\00\00\00\00\79\77\00\00\00\00\00\00\79\40\00\00\00\00\00\00\c7\8c\00\00\00\00\00\00\73\fe\00\00\00\00\00\00\6f\2b\00\00\00\00\00\00\ee\6c\00\00\00\00\00\00\03\52")
(global $D i32 (i32.const 0x180)) ;; pointer to 128 bytes

(data (i32.const 0x200) "\59\f1\00\00\00\00\00\00\b2\26\00\00\00\00\00\00\94\9b\00\00\00\00\00\00\d6\eb\00\00\00\00\00\00\56\b1\00\00\00\00\00\00\83\82\00\00\00\00\00\00\9a\14\00\00\00\00\00\00\e0\00\00\00\00\00\00\00\30\d1\00\00\00\00\00\00\f3\ee\00\00\00\00\00\00\f2\80\00\00\00\00\00\00\8e\19\00\00\00\00\00\00\e7\fc\00\00\00\00\00\00\df\56\00\00\00\00\00\00\dc\d9\00\00\00\00\00\00\06\24")
(global $D2 i32 (i32.const 0x200)) ;; pointer to 128 bytes

(data (i32.const 0x280) "\1a\d5\00\00\00\00\00\00\25\8f\00\00\00\00\00\00\60\2d\00\00\00\00\00\00\56\c9\00\00\00\00\00\00\b2\a7\00\00\00\00\00\00\25\95\00\00\00\00\00\00\60\c7\00\00\00\00\00\00\2c\69\00\00\00\00\00\00\5c\dc\00\00\00\00\00\00\d6\fd\00\00\00\00\00\00\31\e2\00\00\00\00\00\00\a4\c0\00\00\00\00\00\00\fe\53\00\00\00\00\00\00\6e\cd\00\00\00\00\00\00\d3\36\00\00\00\00\00\00\69\21")
(global $X i32 (i32.const 0x280)) ;; pointer to 128 bytes

(data (i32.const 0x300) "\58\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66\00\00\00\00\00\00\66\66")
(global $Y i32 (i32.const 0x300)) ;; pointer to 128 bytes

(data (i32.const 0x380) "\b0\a0\00\00\00\00\00\00\0e\4a\00\00\00\00\00\00\27\1b\00\00\00\00\00\00\ee\c4\00\00\00\00\00\00\78\e4\00\00\00\00\00\00\2f\ad\00\00\00\00\00\00\06\18\00\00\00\00\00\00\43\2f\00\00\00\00\00\00\a7\d7\00\00\00\00\00\00\fb\3d\00\00\00\00\00\00\99\00\00\00\00\00\00\00\4d\2b\00\00\00\00\00\00\0b\df\00\00\00\00\00\00\c1\4f\00\00\00\00\00\00\80\24\00\00\00\00\00\00\83\2b")
(global $I i32 (i32.const 0x380)) ;; pointer to 128 bytes

(data (i32.const 0x400) "\22\ae\28\d7\98\2f\8a\42\cd\65\ef\23\91\44\37\71\2f\3b\4d\ec\cf\fb\c0\b5\bc\db\89\81\a5\db\b5\e9\38\b5\48\f3\5b\c2\56\39\19\d0\05\b6\f1\11\f1\59\9b\4f\19\af\a4\82\3f\92\18\81\6d\da\d5\5e\1c\ab\42\02\03\a3\98\aa\07\d8\be\6f\70\45\01\5b\83\12\8c\b2\e4\4e\be\85\31\24\e2\b4\ff\d5\c3\7d\0c\55\6f\89\7b\f2\74\5d\be\72\b1\96\16\3b\fe\b1\de\80\35\12\c7\25\a7\06\dc\9b\94\26\69\cf\74\f1\9b\c1\d2\4a\f1\9e\c1\69\9b\e4\e3\25\4f\38\86\47\be\ef\b5\d5\8c\8b\c6\9d\c1\0f\65\9c\ac\77\cc\a1\0c\24\75\02\2b\59\6f\2c\e9\2d\83\e4\a6\6e\aa\84\74\4a\d4\fb\41\bd\dc\a9\b0\5c\b5\53\11\83\da\88\f9\76\ab\df\66\ee\52\51\3e\98\10\32\b4\2d\6d\c6\31\a8\3f\21\fb\98\c8\27\03\b0\e4\0e\ef\be\c7\7f\59\bf\c2\8f\a8\3d\f3\0b\e0\c6\25\a7\0a\93\47\91\a7\d5\6f\82\03\e0\51\63\ca\06\70\6e\0e\0a\67\29\29\14\fc\2f\d2\46\85\0a\b7\27\26\c9\26\5c\38\21\1b\2e\ed\2a\c4\5a\fc\6d\2c\4d\df\b3\95\9d\13\0d\38\53\de\63\af\8b\54\73\0a\65\a8\b2\77\3c\bb\0a\6a\76\e6\ae\ed\47\2e\c9\c2\81\3b\35\82\14\85\2c\72\92\64\03\f1\4c\a1\e8\bf\a2\01\30\42\bc\4b\66\1a\a8\91\97\f8\d0\70\8b\4b\c2\30\be\54\06\a3\51\6c\c7\18\52\ef\d6\19\e8\92\d1\10\a9\65\55\24\06\99\d6\2a\20\71\57\85\35\0e\f4\b8\d1\bb\32\70\a0\6a\10\c8\d0\d2\b8\16\c1\a4\19\53\ab\41\51\08\6c\37\1e\99\eb\8e\df\4c\77\48\27\a8\48\9b\e1\b5\bc\b0\34\63\5a\c9\c5\b3\0c\1c\39\cb\8a\41\e3\4a\aa\d8\4e\73\e3\63\77\4f\ca\9c\5b\a3\b8\b2\d6\f3\6f\2e\68\fc\b2\ef\5d\ee\82\8f\74\60\2f\17\43\6f\63\a5\78\72\ab\f0\a1\14\78\c8\84\ec\39\64\1a\08\02\c7\8c\28\1e\63\23\fa\ff\be\90\e9\bd\82\de\eb\6c\50\a4\15\79\c6\b2\f7\a3\f9\be\2b\53\72\e3\f2\78\71\c6\9c\61\26\ea\ce\3e\27\ca\07\c2\c0\21\c7\b8\86\d1\1e\eb\e0\cd\d6\7d\da\ea\78\d1\6e\ee\7f\4f\7d\f5\ba\6f\17\72\aa\67\f0\06\a6\98\c8\a2\c5\7d\63\0a\ae\0d\f9\be\04\98\3f\11\1b\47\1c\13\35\0b\71\1b\84\7d\04\23\f5\77\db\28\93\24\c7\40\7b\ab\ca\32\bc\be\c9\15\0a\be\9e\3c\4c\0d\10\9c\c4\67\1d\43\b6\42\3e\cb\be\d4\c5\4c\2a\7e\65\fc\9c\29\7f\59\ec\fa\d6\3a\ab\6f\cb\5f\17\58\47\4a\8c\19\44\6c")
(global $K i32 (i32.const 0x400)) ;; pointer to 640 bytes

(data (i32.const 0x680) "\ed\00\00\00\00\00\00\00\d3\00\00\00\00\00\00\00\f5\00\00\00\00\00\00\00\5c\00\00\00\00\00\00\00\1a\00\00\00\00\00\00\00\63\00\00\00\00\00\00\00\12\00\00\00\00\00\00\00\58\00\00\00\00\00\00\00\d6\00\00\00\00\00\00\00\9c\00\00\00\00\00\00\00\f7\00\00\00\00\00\00\00\a2\00\00\00\00\00\00\00\de\00\00\00\00\00\00\00\f9\00\00\00\00\00\00\00\de\00\00\00\00\00\00\00\14\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\10")
(global $L i32 (i32.const 0x680)) ;; pointer to 256 bytes

(data (i32.const 0x780) "\09")
(global $_9 i32 (i32.const 0x780)) ;; pointer to 32 bytes

(data (i32.const 0x7a0) "\65\78\70\61\6e\64\20\33\32\2d\62\79\74\65\20\6b")
(global $sigma i32 (i32.const 0x7a0)) ;; pointer to 16 bytes


(global $globalsEnd (export "globalsEnd") i32 (i32.const 0x7b0));; Author: Torsten Stüber

;; input/output pointer $p: 4 * (16 i64) = 512 bytes
;; input pointer $q: 4 * (16 i64) = 512 bytes
;; alloc pointer $alloc: 384 bytes
(func $add (export "add") untrusted
	(param $p i32)
	(param $q i32)
	(param $alloc i32)

	(local $p1 i32) (local $p2 i32) (local $p3 i32)
	(local $t i32) (local $u i32)

	(set_local $p1 (i32.add (get_local $p) (i32.const 128)))
	(set_local $p2 (i32.add (get_local $p) (i32.const 256)))
	(set_local $p3 (i32.add (get_local $p) (i32.const 384)))
	(set_local $t (i32.add (get_local $alloc) (i32.const 128)))
	(set_local $u (i32.add (get_local $alloc) (i32.const 256)))

	(get_local $alloc)
	(get_local $p)
	(get_local $p1)
	(call $A)

	(get_local $u)
	(get_local $q)
	(i32.add (get_local $q) (i32.const 128))
	(call $A)

	(get_local $t)
	(i32.add (get_local $q) (i32.const 128))
	(get_local $q)
	(call $Z)

	(get_local $p1)
	(get_local $p1)
	(get_local $p)
	(call $Z)

	(get_local $p)
	(get_local $alloc)
	(get_local $u)
	(call $M)

	(get_local $p1)
	(get_local $p1)
	(get_local $t)
	(call $M)

	(get_local $p2)
	(get_local $p2)
	(i32.add (get_local $q) (i32.const 256))
	(call $M)

	(get_local $p2)
	(get_local $p2)
	(get_local $p2)
	(call $A)

	(get_local $p3)
	(get_local $p3)
	(i32.add (get_local $q) (i32.const 384))
	(call $M)

	(get_local $p3)
	(get_local $p3)
	(get_global $D2)
	(call $M)

	(get_local $alloc)
	(get_local $p2)
	(get_local $p3)
	(call $A)

	(get_local $p2)
	(get_local $p2)
	(get_local $p3)
	(call $Z)

	(get_local $p3)
	(get_local $p)
	(get_local $p1)
	(call $A)

	(get_local $p)
	(get_local $p)
	(get_local $p1)
	(call $Z)

	(get_local $p1)
	(get_local $p3)
	(get_local $alloc)
	(call $M)

	(get_local $p3)
	(get_local $p)
	(get_local $p3)
	(call $M)

	(get_local $p)
	(get_local $p)
	(get_local $p2)
	(call $M)

	(get_local $p2)
	(get_local $alloc)
	(get_local $p2)
	(call $M)
);; Author: Torsten Stüber

;; input/output pointer $p: 4 * (16 i64) = 512 bytes
;; input/output pointer $q: 4 * (16 i64) = 512 bytes
;; input value $b (is 1 or 0)
(func $cswap (export "cswap") untrusted
	(param $p i32)
	(param $q i32)
	(param $b i32)

	(get_local $p)
	(get_local $q)
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 128))
	(i32.add (get_local $q) (i32.const 128))
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 256))
	(i32.add (get_local $q) (i32.const 256))
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 384))
	(i32.add (get_local $q) (i32.const 384))
	(get_local $b)
	(call $sel25519)
)
;; Author: Torsten Stüber

;; output pointer $r: 32 bytes
;; input/output pointer $x: 64 i64 = 512 bytes
(func $modL (export "modL") untrusted
	(param $r i32)
	(param $x i32)

	(local $carry i64)
	(local $i i32) (local $j i32) (local $k i32) (local $xi i32) (local $xj i32)

	(set_local $i (i32.const 63))
	(set_local $xi (i32.add (get_local $x) (i32.const 504)))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 31)))

			(set_local $carry (i64.const 0))

			(set_local $j (i32.sub (get_local $i) (i32.const 32)))
			(set_local $k (i32.sub (get_local $i) (i32.const 12)))
			(set_local $xj (i32.add (get_local $x) (i32.shl (get_local $j) (i32.const 3))))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $j) (get_local $k)))

					(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (i64.sub
						(get_local $carry)
						(i64.shl
							(i64.mul
								(i64.load (get_local $xi))
								(i64.load (i32.add (get_global $L) (i32.shl (i32.sub
									(get_local $j) 
									(i32.sub (get_local $i) (i32.const 32))
								) (i32.const 3))))
							)
							(i64.const 4)
						)
					)))

					(set_local $carry (i64.shr_s (i64.add
						(i64.load (get_local $xj))
						(i64.const 128)
					) (i64.const 8)))

					(i64.store (get_local $xj) (i64.sub
						(i64.load (get_local $xj))
						(i64.shl (get_local $carry) (i64.const 8))
					))

					(set_local $j (i32.add (get_local $j) (i32.const 1)))
					(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
					(br 0)
				)
			)

			(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (get_local $carry)))
			(i64.store (get_local $xi) (i64.const 0))

			(set_local $i (i32.sub (get_local $i) (i32.const 1)))
			(set_local $xi (i32.sub (get_local $xi) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $carry (i64.const 0))

	(set_local $j (i32.const 0))
	(set_local $xj (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $j) (i32.const 32)))

			(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (i64.sub
				(get_local $carry)
				(i64.mul
					(i64.shr_s (i64.load offset=248 (get_local $x)) (i64.const 4))
					(i64.load (i32.add (get_global $L) (i32.shl (get_local $j) (i32.const 3))))
				)
			)))

			(set_local $carry (i64.shr_s (i64.load (get_local $xj)) (i64.const 8)))

			(i64.store (get_local $xj) (i64.and
				(i64.load (get_local $xj))
				(i64.const 255)
			))

			(set_local $j (i32.add (get_local $j) (i32.const 1)))
			(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $j (i32.const 0))
	(set_local $xj (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $j) (i32.const 32)))

			(i64.store (get_local $xj) (i64.sub (i64.load (get_local $xj))
				(i64.mul (get_local $carry) (i64.load (i32.add
					(get_global $L) 
					(i32.shl (get_local $j) (i32.const 3))
				)))
			))

			(set_local $j (i32.add (get_local $j) (i32.const 1)))
			(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $i (i32.const 0))
	(set_local $xi (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 32)))

			(i64.store offset=8 (get_local $xi) (i64.add
				(i64.load offset=8 (get_local $xi))
				(i64.shr_s (i64.load (get_local $xi)) (i64.const 8))
			))

			(i64.store8 (i32.add (get_local $r) (get_local $i)) (i64.load (get_local $xi)))

			(set_local $i (i32.add (get_local $i) (i32.const 1)))
			(set_local $xi (i32.add (get_local $xi) (i32.const 8)))
			(br 0)
		)
	)
);; Author: Torsten Stüber

;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
;; alloc pointer $alloc: 64 + 256 = 384 bytes
;; return bool
(func $neq25519 (export "neq25519") untrusted
	(param $a i32)
	(param $b i32)
	(param $alloc i32)
	(result i32)

	(get_local $alloc)
	(get_local $a)
	(i32.add (get_local $alloc) (i32.const 64))
	(call $pack25519)

	(i32.add (get_local $alloc) (i32.const 32))
	(get_local $b)
	(i32.add (get_local $alloc) (i32.const 64))
	(call $pack25519)

	(get_local $alloc)
	(i32.add (get_local $alloc) (i32.const 32))
	(call $crypto_verify_32)
)
;; Author: Torsten Stüber

;; output pointer $r: 32 bytes
;; input pointer $p: 4 * (16 i64) = 512 bytes
;; alloc pointer $alloc: 512 bytes
(func $pack (export "pack") untrusted
	(param $r i32)
	(param $p i32)
	(param $alloc i32)

	(local $ty i32) (local $zi i32)

	(set_local $ty (i32.add (get_local $p) (i32.const 128)))
	(tee_local $zi (i32.add (get_local $p) (i32.const 256)))

	(i32.add (get_local $p) (i32.const 256))
	(get_local $alloc)
	(call $inv25519)

	(get_local $alloc)
	(get_local $p)
	(get_local $zi)
	(call $M)

	(get_local $ty)
	(i32.add (get_local $p) (i32.const 128))
	(get_local $zi)
	(call $M)

	(get_local $r)
	(get_local $ty)
	(get_local $zi)
	(call $pack25519)

	
	(i32.store8 offset=31 (get_local $r) (i32.xor (i32.load8_u offset=31 (get_local $r))
		(i32.shl (call $par25519 (get_local $alloc) (get_local $ty)) (i32.const 7))
	))
);; Author: Torsten Stüber

;; input pointer $a: 16 i64 = 128 bytes
;; alloc pointer $alloc: 256 + 128 = 384 bytes
;; return value: 1 or 0
(func $par25519 (export "par25519") untrusted
	(param $a i32)
	(param $alloc i32)
	(result i32)

	(local $d i32)
	(tee_local $d (i32.add (get_local $alloc) (i32.const 256)))

	(get_local $a)
	(get_local $alloc)
	(call $pack25519)

	(i32.and (i32.const 1) (i32.load8_u (get_local $d)))
)
;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $i: 16 i64 = 128 bytes
;; alloc pointer $alloc: 16 i64 = 128 bytes
(func $pow2523 (export "pow2523") untrusted
	(param $o i32)
	(param $i i32)
	(param $alloc i32)

	(local $a i32)

	(i64.store offset=0 (get_local $alloc) (i64.load offset=0 (get_local $i)))
	(i64.store offset=8 (get_local $alloc) (i64.load offset=8 (get_local $i)))
	(i64.store offset=16 (get_local $alloc) (i64.load offset=16 (get_local $i)))
	(i64.store offset=24 (get_local $alloc) (i64.load offset=24 (get_local $i)))
	(i64.store offset=32 (get_local $alloc) (i64.load offset=32 (get_local $i)))
	(i64.store offset=40 (get_local $alloc) (i64.load offset=40 (get_local $i)))
	(i64.store offset=48 (get_local $alloc) (i64.load offset=48 (get_local $i)))
	(i64.store offset=56 (get_local $alloc) (i64.load offset=56 (get_local $i)))
	(i64.store offset=64 (get_local $alloc) (i64.load offset=64 (get_local $i)))
	(i64.store offset=72 (get_local $alloc) (i64.load offset=72 (get_local $i)))
	(i64.store offset=80 (get_local $alloc) (i64.load offset=80 (get_local $i)))
	(i64.store offset=88 (get_local $alloc) (i64.load offset=88 (get_local $i)))
	(i64.store offset=96 (get_local $alloc) (i64.load offset=96 (get_local $i)))
	(i64.store offset=104 (get_local $alloc) (i64.load offset=104 (get_local $i)))
	(i64.store offset=112 (get_local $alloc) (i64.load offset=112 (get_local $i)))
	(i64.store offset=120 (get_local $alloc) (i64.load offset=120 (get_local $i)))
	

	(set_local $a (i32.const 251))

	(block
		(loop
			(br_if 1 (i32.eqz (get_local $a)))
			(get_local $alloc)
			(get_local $alloc)
			(call $S)

			(if (i32.ne (get_local $a) (i32.const 2))
				(then
					(get_local $alloc)
					(get_local $alloc)
					(get_local $i)
					(call $M)
				)
			)

			(set_local $a (i32.sub (get_local $a) (i32.const 1)))
			(br 0)
		)
	)

	(i64.store offset=0 (get_local $o) (i64.load offset=0 (get_local $alloc)))
	(i64.store offset=8 (get_local $o) (i64.load offset=8 (get_local $alloc)))
	(i64.store offset=16 (get_local $o) (i64.load offset=16 (get_local $alloc)))
	(i64.store offset=24 (get_local $o) (i64.load offset=24 (get_local $alloc)))
	(i64.store offset=32 (get_local $o) (i64.load offset=32 (get_local $alloc)))
	(i64.store offset=40 (get_local $o) (i64.load offset=40 (get_local $alloc)))
	(i64.store offset=48 (get_local $o) (i64.load offset=48 (get_local $alloc)))
	(i64.store offset=56 (get_local $o) (i64.load offset=56 (get_local $alloc)))
	(i64.store offset=64 (get_local $o) (i64.load offset=64 (get_local $alloc)))
	(i64.store offset=72 (get_local $o) (i64.load offset=72 (get_local $alloc)))
	(i64.store offset=80 (get_local $o) (i64.load offset=80 (get_local $alloc)))
	(i64.store offset=88 (get_local $o) (i64.load offset=88 (get_local $alloc)))
	(i64.store offset=96 (get_local $o) (i64.load offset=96 (get_local $alloc)))
	(i64.store offset=104 (get_local $o) (i64.load offset=104 (get_local $alloc)))
	(i64.store offset=112 (get_local $o) (i64.load offset=112 (get_local $alloc)))
	(i64.store offset=120 (get_local $o) (i64.load offset=120 (get_local $alloc)))

);; Author: Torsten Stüber

;; input/output pointer $r: 64 bytes
;; alloc pointer $alloc: 64 i64 = 512 bytes
(func $reduce (export "reduce") untrusted
	(param $r i32)
	(param $alloc i32)

	(local $i i32)


	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 64)))

			(i64.store (i32.add (get_local $alloc) (i32.shl (get_local $i) (i32.const 3))) (
				i64.load8_u (i32.add (get_local $r) (get_local $i))
			))

			(set_local $i (i32.add (get_local $i) (i32.const 1)))
			(br 0)
		)
	)

	(i64.store offset=0 (get_local $r) (i64.const 0))
	(i64.store offset=8 (get_local $r) (i64.const 0))
	(i64.store offset=16 (get_local $r) (i64.const 0))
	(i64.store offset=24 (get_local $r) (i64.const 0))
	(i64.store offset=32 (get_local $r) (i64.const 0))
	(i64.store offset=40 (get_local $r) (i64.const 0))
	(i64.store offset=48 (get_local $r) (i64.const 0))
	(i64.store offset=56 (get_local $r) (i64.const 0))

	(get_local $r)
	(get_local $alloc)
	(call $modL)
)
;; Author: Torsten Stüber

;; output pointer $p: 4 * (16 i64) = 512 bytes
;; input pointer $s: 64 bytes
;; alloc pointer $alloc: 512 + 384 = 896 bytes
(func $scalarbase (export "scalarbase") untrusted
	(param $p i32)
	(param $s i32)
	(param $alloc i32)

	(get_local $alloc)
	(get_global $X)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 128))
	(get_global $Y)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 384))
	(get_global $X)
	(get_global $Y)
	(call $M)

	(get_local $p)
	(get_local $alloc)
	(get_local $s)
	(i32.add (get_local $alloc) (i32.const 512))
	(call $scalarmult)
);; Author: Torsten Stüber

;; output pointer $p: 4 * (16 i64) = 512 bytes
;; input/output pointer $q: 4 * (16 i64) = 512 bytes
;; input pointer $s: 64 bytes
;; alloc pointer $alloc: 384 bytes
(func $scalarmult (export "scalarmult") untrusted
	(param $p i32)
	(param $q i32)
	(param $s i32)
	(param $alloc i32)

	(local $b i32) (local $i i32)

	(get_local $p)
	(get_global $gf0)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 128))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 384))
	(get_global $gf0)
	(call $set25519)

	(set_local $i (i32.const 255))
	(block
		(loop
			(set_local $b (i32.and (i32.shr_u
				(i32.load8_u (i32.add (get_local $s) (i32.shr_u (get_local $i) (i32.const 3))))
				(i32.and (get_local $i) (i32.const 7))
			) (i32.const 1)))

			(get_local $p)
			(get_local $q)
			(get_local $b)
			(call $cswap)

			(get_local $q)
			(get_local $p)
			(get_local $alloc)
			(call $add)

			(get_local $p)
			(get_local $p)
			(get_local $alloc)
			(call $add)

			(get_local $p)
			(get_local $q)
			(get_local $b)
			(call $cswap)

			(set_local $i (i32.sub (get_local $i) (i32.const 1)))
			(br_if 0 (i32.ge_s (get_local $i) (i32.const 0)))
			(br 1)
		)
	)
)
;; Author: Torsten Stüber

;; output pointer $r: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
(func $set25519 (export "set25519") untrusted
	(param $r i32)
	(param $a i32)

	(i64.store offset=0 (get_local $r) (i64.load offset=0 (get_local $a)))
	(i64.store offset=8 (get_local $r) (i64.load offset=8 (get_local $a)))
	(i64.store offset=16 (get_local $r) (i64.load offset=16 (get_local $a)))
	(i64.store offset=24 (get_local $r) (i64.load offset=24 (get_local $a)))
	(i64.store offset=32 (get_local $r) (i64.load offset=32 (get_local $a)))
	(i64.store offset=40 (get_local $r) (i64.load offset=40 (get_local $a)))
	(i64.store offset=48 (get_local $r) (i64.load offset=48 (get_local $a)))
	(i64.store offset=56 (get_local $r) (i64.load offset=56 (get_local $a)))
	(i64.store offset=64 (get_local $r) (i64.load offset=64 (get_local $a)))
	(i64.store offset=72 (get_local $r) (i64.load offset=72 (get_local $a)))
	(i64.store offset=80 (get_local $r) (i64.load offset=80 (get_local $a)))
	(i64.store offset=88 (get_local $r) (i64.load offset=88 (get_local $a)))
	(i64.store offset=96 (get_local $r) (i64.load offset=96 (get_local $a)))
	(i64.store offset=104 (get_local $r) (i64.load offset=104 (get_local $a)))
	(i64.store offset=112 (get_local $r) (i64.load offset=112 (get_local $a)))
	(i64.store offset=120 (get_local $r) (i64.load offset=120 (get_local $a)))
);; Author: Torsten Stüber

;; output pointer $r: 4 * (16 i64) = 512 bytes
;; input pointer $p: 32 bytes
;; alloc pointer $alloc: 7 * 128 = 896 bytes
;; return bool
(func $unpackneg (export "unpackneg") 
	(param $r i32)
	(param $p i32)
	(param $alloc i32)
	(result i32)

	(local $t i32)
	(local $chk i32)
	(local $num i32)
	(local $den i32)
	(local $den2 i32)
	(local $den4 i32)
	(local $den6 i32)

	(tee_local $t (get_local $alloc))
	(tee_local $chk (i32.add (i32.const 128)))
	(tee_local $num (i32.add (i32.const 128)))
	(tee_local $den (i32.add (i32.const 128)))
	(tee_local $den2 (i32.add (i32.const 128)))
	(tee_local $den4 (i32.add (i32.const 128)))
	(set_local $den6 (i32.add (i32.const 128)))

	(i32.add (get_local $r) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $r) (i32.const 128))
	(get_local $p)
	(call $unpack25519)

	(get_local $num)
	(i32.add (get_local $r) (i32.const 128))
	(call $S)

	(get_local $den)
	(get_local $num)
	(get_global $D)
	(call $M)

	(get_local $num)
	(get_local $num)
	(i32.add (get_local $r) (i32.const 256))
	(call $Z)

	(get_local $den)
	(i32.add (get_local $r) (i32.const 256))
	(get_local $den)
	(call $A)

	
	(get_local $den2)
	(get_local $den)
	(call $S)

	(get_local $den4)
	(get_local $den2)
	(call $S)

	(get_local $den6)
	(get_local $den4)
	(get_local $den2)
	(call $M)

	(get_local $t)
	(get_local $den6)
	(get_local $num)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)


	(get_local $t)
	(get_local $t)
	(get_local $den2)
	(call $pow2523)

	(get_local $t)
	(get_local $t)
	(get_local $num)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)

	(get_local $r)
	(get_local $t)
	(get_local $den)
	(call $M)


	(get_local $chk)
	(get_local $r)
	(call $S)

	(get_local $chk)
	(get_local $chk)
	(get_local $den)
	(call $M)

	(if (call $neq25519 (get_local $chk) (get_local $num) (get_local $den2))
		(then
			(get_local $r)
			(get_local $r)
			(get_global $I)
			(call $M)
		)
	)


	(get_local $chk)
	(get_local $r)
	(call $S)

	(get_local $chk)
	(get_local $chk)
	(get_local $den)
	(call $M)

	(if (call $neq25519 (get_local $chk) (get_local $num) (get_local $den2))
		(then
			(i32.const -1)
			(return)
		)
	)

	(if (i32.eq
        (call $par25519 (get_local $r) (get_local $den2))
        (i32.shr_u (i32.load8_u offset=31 (get_local $p)) (i32.const 7))
        )
		(then
			(get_local $r)
			(get_global $gf0)
			(get_local $r)
			(call $Z)
		)
	)

	(i32.add (get_local $r) (i32.const 384))
	(get_local $r)
	(i32.add (get_local $r) (i32.const 128))
	(call $M)

	(i32.const 0)
)
;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
(func $A (export "A") untrusted
	(param $o i32)
	(param $a i32)
	(param $b i32)

	(i64.store offset=0 (get_local $o) (i64.add (i64.load offset=0 (get_local $a)) (i64.load offset=0 (get_local $b))))
	(i64.store offset=8 (get_local $o) (i64.add (i64.load offset=8 (get_local $a)) (i64.load offset=8 (get_local $b))))
	(i64.store offset=16 (get_local $o) (i64.add (i64.load offset=16 (get_local $a)) (i64.load offset=16 (get_local $b))))
	(i64.store offset=24 (get_local $o) (i64.add (i64.load offset=24 (get_local $a)) (i64.load offset=24 (get_local $b))))
	(i64.store offset=32 (get_local $o) (i64.add (i64.load offset=32 (get_local $a)) (i64.load offset=32 (get_local $b))))
	(i64.store offset=40 (get_local $o) (i64.add (i64.load offset=40 (get_local $a)) (i64.load offset=40 (get_local $b))))
	(i64.store offset=48 (get_local $o) (i64.add (i64.load offset=48 (get_local $a)) (i64.load offset=48 (get_local $b))))
	(i64.store offset=56 (get_local $o) (i64.add (i64.load offset=56 (get_local $a)) (i64.load offset=56 (get_local $b))))
	(i64.store offset=64 (get_local $o) (i64.add (i64.load offset=64 (get_local $a)) (i64.load offset=64 (get_local $b))))
	(i64.store offset=72 (get_local $o) (i64.add (i64.load offset=72 (get_local $a)) (i64.load offset=72 (get_local $b))))
	(i64.store offset=80 (get_local $o) (i64.add (i64.load offset=80 (get_local $a)) (i64.load offset=80 (get_local $b))))
	(i64.store offset=88 (get_local $o) (i64.add (i64.load offset=88 (get_local $a)) (i64.load offset=88 (get_local $b))))
	(i64.store offset=96 (get_local $o) (i64.add (i64.load offset=96 (get_local $a)) (i64.load offset=96 (get_local $b))))
	(i64.store offset=104 (get_local $o) (i64.add (i64.load offset=104 (get_local $a)) (i64.load offset=104 (get_local $b))))
	(i64.store offset=112 (get_local $o) (i64.add (i64.load offset=112 (get_local $a)) (i64.load offset=112 (get_local $b))))
	(i64.store offset=120 (get_local $o) (i64.add (i64.load offset=120 (get_local $a)) (i64.load offset=120 (get_local $b))))
	
);; Author: Torsten Stüber

;; input/output pointer $o: 16 i64 = 128 bytes
(func $car25519 (export "car25519") untrusted
	(param $o i32)

	(local $v i64)
	(local $c i64)

	(set_local $c (i64.const 1))
	(set_local $v (i64.add (i64.add (i64.load offset=0 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=0 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=8 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=8 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=16 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=16 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=24 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=24 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=32 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=32 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=40 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=40 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=48 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=48 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=56 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=56 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=64 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=64 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=72 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=72 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=80 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=80 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=88 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=88 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=96 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=96 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=104 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=104 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=112 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=112 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (i64.load offset=120 (get_local $o)) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(i64.store offset=120 (get_local $o) (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(i64.store offset=0 (get_local $o) (i64.add (i64.load offset=0 (get_local $o)) (i64.mul (i64.const 38) (i64.sub (get_local $c) (i64.const 1)))))
);; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $i: 16 i64 = 128 bytes
;; alloc pointer $alloc: 128 bytes
(func $inv25519 (export "inv25519") untrusted
	(param $o i32)
	(param $i i32)
	(param $alloc i32)

	(local $a i32)

	(i64.store offset=0 (get_local $alloc) (i64.load offset=0 (get_local $i)))
	(i64.store offset=8 (get_local $alloc) (i64.load offset=8 (get_local $i)))
	(i64.store offset=16 (get_local $alloc) (i64.load offset=16 (get_local $i)))
	(i64.store offset=24 (get_local $alloc) (i64.load offset=24 (get_local $i)))
	(i64.store offset=32 (get_local $alloc) (i64.load offset=32 (get_local $i)))
	(i64.store offset=40 (get_local $alloc) (i64.load offset=40 (get_local $i)))
	(i64.store offset=48 (get_local $alloc) (i64.load offset=48 (get_local $i)))
	(i64.store offset=56 (get_local $alloc) (i64.load offset=56 (get_local $i)))
	(i64.store offset=64 (get_local $alloc) (i64.load offset=64 (get_local $i)))
	(i64.store offset=72 (get_local $alloc) (i64.load offset=72 (get_local $i)))
	(i64.store offset=80 (get_local $alloc) (i64.load offset=80 (get_local $i)))
	(i64.store offset=88 (get_local $alloc) (i64.load offset=88 (get_local $i)))
	(i64.store offset=96 (get_local $alloc) (i64.load offset=96 (get_local $i)))
	(i64.store offset=104 (get_local $alloc) (i64.load offset=104 (get_local $i)))
	(i64.store offset=112 (get_local $alloc) (i64.load offset=112 (get_local $i)))
	(i64.store offset=120 (get_local $alloc) (i64.load offset=120 (get_local $i)))

	(set_local $a (i32.const 253))

	(block
		(loop
			(br_if 1 (i32.lt_s (get_local $a) (i32.const 0)))

			(get_local $alloc)
			(get_local $alloc)
			(call $S)

			(if (i32.and (i32.ne (get_local $a) (i32.const 2)) (i32.ne (get_local $a) (i32.const 4)))
				(then
					(get_local $alloc)
					(get_local $alloc)
					(get_local $i)
					(call $M)
				)
			)

			(set_local $a (i32.sub (get_local $a) (i32.const 1)))
			(br 0)
		)
	)

	(i64.store offset=0 (get_local $o) (i64.load offset=0 (get_local $alloc)))
	(i64.store offset=8 (get_local $o) (i64.load offset=8 (get_local $alloc)))
	(i64.store offset=16 (get_local $o) (i64.load offset=16 (get_local $alloc)))
	(i64.store offset=24 (get_local $o) (i64.load offset=24 (get_local $alloc)))
	(i64.store offset=32 (get_local $o) (i64.load offset=32 (get_local $alloc)))
	(i64.store offset=40 (get_local $o) (i64.load offset=40 (get_local $alloc)))
	(i64.store offset=48 (get_local $o) (i64.load offset=48 (get_local $alloc)))
	(i64.store offset=56 (get_local $o) (i64.load offset=56 (get_local $alloc)))
	(i64.store offset=64 (get_local $o) (i64.load offset=64 (get_local $alloc)))
	(i64.store offset=72 (get_local $o) (i64.load offset=72 (get_local $alloc)))
	(i64.store offset=80 (get_local $o) (i64.load offset=80 (get_local $alloc)))
	(i64.store offset=88 (get_local $o) (i64.load offset=88 (get_local $alloc)))
	(i64.store offset=96 (get_local $o) (i64.load offset=96 (get_local $alloc)))
	(i64.store offset=104 (get_local $o) (i64.load offset=104 (get_local $alloc)))
	(i64.store offset=112 (get_local $o) (i64.load offset=112 (get_local $alloc)))
	(i64.store offset=120 (get_local $o) (i64.load offset=120 (get_local $alloc)))
);; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
(func $M (export "M") untrusted
	(param $o i32)
	(param $a i32)
	(param $b i32)

	(local $v i64) (local $c i64)
	(local $t0 i64) (local $t1 i64) (local $t2 i64) (local $t3 i64)
	(local $t4 i64) (local $t5 i64) (local $t6 i64) (local $t7 i64)
	(local $t8 i64) (local $t9 i64) (local $t10 i64) (local $t11 i64)
	(local $t12 i64) (local $t13 i64) (local $t14 i64) (local $t15 i64)
	(local $t16 i64) (local $t17 i64) (local $t18 i64) (local $t19 i64)
	(local $t20 i64) (local $t21 i64) (local $t22 i64) (local $t23 i64)
	(local $t24 i64) (local $t25 i64) (local $t26 i64) (local $t27 i64)
	(local $t28 i64) (local $t29 i64) (local $t30 i64)
	(local $b0 i64) (local $b1 i64) (local $b2 i64) (local $b3 i64)
	(local $b4 i64) (local $b5 i64) (local $b6 i64) (local $b7 i64)
	(local $b8 i64) (local $b9 i64) (local $b10 i64) (local $b11 i64)
	(local $b12 i64) (local $b13 i64) (local $b14 i64) (local $b15 i64)

	(set_local $b0 (i64.load offset=0 (get_local $b)))
	(set_local $b1 (i64.load offset=8 (get_local $b)))
	(set_local $b2 (i64.load offset=16 (get_local $b)))
	(set_local $b3 (i64.load offset=24 (get_local $b)))
	(set_local $b4 (i64.load offset=32 (get_local $b)))
	(set_local $b5 (i64.load offset=40 (get_local $b)))
	(set_local $b6 (i64.load offset=48 (get_local $b)))
	(set_local $b7 (i64.load offset=56 (get_local $b)))
	(set_local $b8 (i64.load offset=64 (get_local $b)))
	(set_local $b9 (i64.load offset=72 (get_local $b)))
	(set_local $b10 (i64.load offset=80 (get_local $b)))
	(set_local $b11 (i64.load offset=88 (get_local $b)))
	(set_local $b12 (i64.load offset=96 (get_local $b)))
	(set_local $b13 (i64.load offset=104 (get_local $b)))
	(set_local $b14 (i64.load offset=112 (get_local $b)))
	(set_local $b15 (i64.load offset=120 (get_local $b)))

	(set_local $v (i64.load offset=0 (get_local $a)))
	(set_local $t0 (i64.add (get_local $t0) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t1 (i64.add (get_local $t1) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t2 (i64.add (get_local $t2) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t3 (i64.add (get_local $t3) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=8 (get_local $a)))
	(set_local $t1 (i64.add (get_local $t1) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t2 (i64.add (get_local $t2) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t3 (i64.add (get_local $t3) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=16 (get_local $a)))
	(set_local $t2 (i64.add (get_local $t2) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t3 (i64.add (get_local $t3) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=24 (get_local $a)))
	(set_local $t3 (i64.add (get_local $t3) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=32 (get_local $a)))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=40 (get_local $a)))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=48 (get_local $a)))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=56 (get_local $a)))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=64 (get_local $a)))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=72 (get_local $a)))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=80 (get_local $a)))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=88 (get_local $a)))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t26 (i64.add (get_local $t26) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=96 (get_local $a)))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t26 (i64.add (get_local $t26) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t27 (i64.add (get_local $t27) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=104 (get_local $a)))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t26 (i64.add (get_local $t26) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t27 (i64.add (get_local $t27) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t28 (i64.add (get_local $t28) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=112 (get_local $a)))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t26 (i64.add (get_local $t26) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t27 (i64.add (get_local $t27) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t28 (i64.add (get_local $t28) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t29 (i64.add (get_local $t29) (i64.mul (get_local $v) (get_local $b15))))
	(set_local $v (i64.load offset=120 (get_local $a)))
	(set_local $t15 (i64.add (get_local $t15) (i64.mul (get_local $v) (get_local $b0))))
	(set_local $t16 (i64.add (get_local $t16) (i64.mul (get_local $v) (get_local $b1))))
	(set_local $t17 (i64.add (get_local $t17) (i64.mul (get_local $v) (get_local $b2))))
	(set_local $t18 (i64.add (get_local $t18) (i64.mul (get_local $v) (get_local $b3))))
	(set_local $t19 (i64.add (get_local $t19) (i64.mul (get_local $v) (get_local $b4))))
	(set_local $t20 (i64.add (get_local $t20) (i64.mul (get_local $v) (get_local $b5))))
	(set_local $t21 (i64.add (get_local $t21) (i64.mul (get_local $v) (get_local $b6))))
	(set_local $t22 (i64.add (get_local $t22) (i64.mul (get_local $v) (get_local $b7))))
	(set_local $t23 (i64.add (get_local $t23) (i64.mul (get_local $v) (get_local $b8))))
	(set_local $t24 (i64.add (get_local $t24) (i64.mul (get_local $v) (get_local $b9))))
	(set_local $t25 (i64.add (get_local $t25) (i64.mul (get_local $v) (get_local $b10))))
	(set_local $t26 (i64.add (get_local $t26) (i64.mul (get_local $v) (get_local $b11))))
	(set_local $t27 (i64.add (get_local $t27) (i64.mul (get_local $v) (get_local $b12))))
	(set_local $t28 (i64.add (get_local $t28) (i64.mul (get_local $v) (get_local $b13))))
	(set_local $t29 (i64.add (get_local $t29) (i64.mul (get_local $v) (get_local $b14))))
	(set_local $t30 (i64.add (get_local $t30) (i64.mul (get_local $v) (get_local $b15))))

	(set_local $t0 (i64.add (get_local $t0) (i64.mul (i64.const 38) (get_local $t16))))
	(set_local $t1 (i64.add (get_local $t1) (i64.mul (i64.const 38) (get_local $t17))))
	(set_local $t2 (i64.add (get_local $t2) (i64.mul (i64.const 38) (get_local $t18))))
	(set_local $t3 (i64.add (get_local $t3) (i64.mul (i64.const 38) (get_local $t19))))
	(set_local $t4 (i64.add (get_local $t4) (i64.mul (i64.const 38) (get_local $t20))))
	(set_local $t5 (i64.add (get_local $t5) (i64.mul (i64.const 38) (get_local $t21))))
	(set_local $t6 (i64.add (get_local $t6) (i64.mul (i64.const 38) (get_local $t22))))
	(set_local $t7 (i64.add (get_local $t7) (i64.mul (i64.const 38) (get_local $t23))))
	(set_local $t8 (i64.add (get_local $t8) (i64.mul (i64.const 38) (get_local $t24))))
	(set_local $t9 (i64.add (get_local $t9) (i64.mul (i64.const 38) (get_local $t25))))
	(set_local $t10 (i64.add (get_local $t10) (i64.mul (i64.const 38) (get_local $t26))))
	(set_local $t11 (i64.add (get_local $t11) (i64.mul (i64.const 38) (get_local $t27))))
	(set_local $t12 (i64.add (get_local $t12) (i64.mul (i64.const 38) (get_local $t28))))
	(set_local $t13 (i64.add (get_local $t13) (i64.mul (i64.const 38) (get_local $t29))))
	(set_local $t14 (i64.add (get_local $t14) (i64.mul (i64.const 38) (get_local $t30))))

	(set_local $c (i64.const 1))
	(set_local $v (i64.add (i64.add (get_local $t0) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t0 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t1) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t1 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t2) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t2 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t3) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t3 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t4) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t4 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t5) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t5 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t6) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t6 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t7) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t7 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t8) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t8 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t9) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t9 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t10) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t10 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t11) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t11 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t12) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t12 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t13) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t13 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t14) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t14 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t15) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t15 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $t0 (i64.add (get_local $t0) (i64.mul (i64.const 38) (i64.sub (get_local $c) (i64.const 1)))))

	(set_local $c (i64.const 1))
	(set_local $v (i64.add (i64.add (get_local $t0) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t0 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t1) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t1 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t2) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t2 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t3) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t3 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t4) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t4 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t5) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t5 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t6) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t6 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t7) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t7 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t8) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t8 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t9) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t9 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t10) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t10 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t11) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t11 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t12) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t12 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t13) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t13 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t14) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t14 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $v (i64.add (i64.add (get_local $t15) (get_local $c)) (i64.const 65535)))
	(set_local $c (i64.shr_s (get_local $v) (i64.const 16)))
	(set_local $t15 (i64.sub (get_local $v) (i64.shl (get_local $c) (i64.const 16))))
	(set_local $t0 (i64.add (get_local $t0) (i64.mul (i64.const 38) (i64.sub (get_local $c) (i64.const 1)))))

	(i64.store offset=0 (get_local $o) (get_local $t0))
	(i64.store offset=8 (get_local $o) (get_local $t1))
	(i64.store offset=16 (get_local $o) (get_local $t2))
	(i64.store offset=24 (get_local $o) (get_local $t3))
	(i64.store offset=32 (get_local $o) (get_local $t4))
	(i64.store offset=40 (get_local $o) (get_local $t5))
	(i64.store offset=48 (get_local $o) (get_local $t6))
	(i64.store offset=56 (get_local $o) (get_local $t7))
	(i64.store offset=64 (get_local $o) (get_local $t8))
	(i64.store offset=72 (get_local $o) (get_local $t9))
	(i64.store offset=80 (get_local $o) (get_local $t10))
	(i64.store offset=88 (get_local $o) (get_local $t11))
	(i64.store offset=96 (get_local $o) (get_local $t12))
	(i64.store offset=104 (get_local $o) (get_local $t13))
	(i64.store offset=112 (get_local $o) (get_local $t14))
	(i64.store offset=120 (get_local $o) (get_local $t15))
);; Author: Torsten Stüber

;; output pointer $o: 32 bytes
;; input pointer $n: 16 i64 = 128 bytes
;; alloc pointer $alloc: 256 bytes
(func $pack25519 (export "pack25519") untrusted
	(param $o i32)
	(param $n i32)
	(param $alloc i32)

	(local $b i32)
	(local $m i32)
	(local $t i32)

	(tee_local $m (get_local $alloc))
	(set_local $t (i32.add (i32.const 128)))

	(i64.store offset=0 (get_local $t) (i64.load offset=0 (get_local $n)))
	(i64.store offset=8 (get_local $t) (i64.load offset=8 (get_local $n)))
	(i64.store offset=16 (get_local $t) (i64.load offset=16 (get_local $n)))
	(i64.store offset=24 (get_local $t) (i64.load offset=24 (get_local $n)))
	(i64.store offset=32 (get_local $t) (i64.load offset=32 (get_local $n)))
	(i64.store offset=40 (get_local $t) (i64.load offset=40 (get_local $n)))
	(i64.store offset=48 (get_local $t) (i64.load offset=48 (get_local $n)))
	(i64.store offset=56 (get_local $t) (i64.load offset=56 (get_local $n)))
	(i64.store offset=64 (get_local $t) (i64.load offset=64 (get_local $n)))
	(i64.store offset=72 (get_local $t) (i64.load offset=72 (get_local $n)))
	(i64.store offset=80 (get_local $t) (i64.load offset=80 (get_local $n)))
	(i64.store offset=88 (get_local $t) (i64.load offset=88 (get_local $n)))
	(i64.store offset=96 (get_local $t) (i64.load offset=96 (get_local $n)))
	(i64.store offset=104 (get_local $t) (i64.load offset=104 (get_local $n)))
	(i64.store offset=112 (get_local $t) (i64.load offset=112 (get_local $n)))
	(i64.store offset=120 (get_local $t) (i64.load offset=120 (get_local $n)))

	(get_local $t)
	(call $car25519)
	(get_local $t)
	(call $car25519)
	(get_local $t)
	(call $car25519)

	
	(i64.store offset=0 (get_local $m) (i64.sub (i64.load offset=0 (get_local $t)) (i64.const 0xffed)))
	(i64.store offset=8 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=8 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=0 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=0 (get_local $m) (i64.and (i64.load offset=0 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=16 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=16 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=8 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=8 (get_local $m) (i64.and (i64.load offset=8 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=24 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=24 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=16 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=16 (get_local $m) (i64.and (i64.load offset=16 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=32 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=32 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=24 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=24 (get_local $m) (i64.and (i64.load offset=24 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=40 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=40 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=32 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=32 (get_local $m) (i64.and (i64.load offset=32 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=48 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=48 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=40 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=40 (get_local $m) (i64.and (i64.load offset=40 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=56 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=56 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=48 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=48 (get_local $m) (i64.and (i64.load offset=48 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=64 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=64 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=56 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=56 (get_local $m) (i64.and (i64.load offset=56 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=72 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=72 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=64 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=64 (get_local $m) (i64.and (i64.load offset=64 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=80 (get_local $m) (i64.sub 
		(i64.sub (i64.load offset=80 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=72 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=72 (get_local $m) (i64.and (i64.load offset=72 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=88 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=88 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=80 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=80 (get_local $m) (i64.and (i64.load offset=80 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=96 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=96 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=88 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=88 (get_local $m) (i64.and (i64.load offset=88 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=104 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=104 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=96 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=96 (get_local $m) (i64.and (i64.load offset=96 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=112 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=112 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=104 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=104 (get_local $m) (i64.and (i64.load offset=104 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=120 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=120 (get_local $t)) (i64.const 0x7fff)) 
		(i64.and (i64.shr_s (i64.load offset=112 (get_local $m)) (i64.const 16)) (i64.const 1))
	))

	(set_local $b (i32.wrap/i64 (i64.and
		(i64.shr_s (i64.load offset=120 (get_local $m)) (i64.const 16))
		(i64.const 1)
	)))
	(i64.store offset=112 (get_local $m) (i64.and (i64.load offset=112 (get_local $m)) (i64.const 0xffff)))

	(get_local $t)
	(get_local $m)
	(i32.sub (i32.const 1) (get_local $b))
	(call $sel25519)


	(i64.store offset=0 (get_local $m) (i64.sub (i64.load offset=0 (get_local $t)) (i64.const 0xffed)))
	(i64.store offset=8 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=8 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=0 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=0 (get_local $m) (i64.and (i64.load offset=0 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=16 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=16 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=8 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=8 (get_local $m) (i64.and (i64.load offset=8 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=24 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=24 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=16 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=16 (get_local $m) (i64.and (i64.load offset=16 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=32 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=32 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=24 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=24 (get_local $m) (i64.and (i64.load offset=24 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=40 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=40 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=32 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=32 (get_local $m) (i64.and (i64.load offset=32 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=48 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=48 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=40 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=40 (get_local $m) (i64.and (i64.load offset=40 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=56 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=56 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=48 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=48 (get_local $m) (i64.and (i64.load offset=48 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=64 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=64 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=56 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=56 (get_local $m) (i64.and (i64.load offset=56 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=72 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=72 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=64 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=64 (get_local $m) (i64.and (i64.load offset=64 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=80 (get_local $m) (i64.sub 
		(i64.sub (i64.load offset=80 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=72 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=72 (get_local $m) (i64.and (i64.load offset=72 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=88 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=88 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=80 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=80 (get_local $m) (i64.and (i64.load offset=80 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=96 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=96 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=88 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=88 (get_local $m) (i64.and (i64.load offset=88 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=104 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=104 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=96 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=96 (get_local $m) (i64.and (i64.load offset=96 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=112 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=112 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=104 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=104 (get_local $m) (i64.and (i64.load offset=104 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=120 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=120 (get_local $t)) (i64.const 0x7fff)) 
		(i64.and (i64.shr_s (i64.load offset=112 (get_local $m)) (i64.const 16)) (i64.const 1))
	))

	(set_local $b (i32.wrap/i64 (i64.and
		(i64.shr_s (i64.load offset=120 (get_local $m)) (i64.const 16))
		(i64.const 1)
	)))
	(i64.store offset=112 (get_local $m) (i64.and (i64.load offset=112 (get_local $m)) (i64.const 0xffff)))

	(get_local $t)
	(get_local $m)
	(i32.sub (i32.const 1) (get_local $b))
	(call $sel25519)

	(i64.store16 offset=0 (get_local $o) (i64.load offset=0 (get_local $t)))
	(i64.store16 offset=2 (get_local $o) (i64.load offset=8 (get_local $t)))
	(i64.store16 offset=4 (get_local $o) (i64.load offset=16 (get_local $t)))
	(i64.store16 offset=6 (get_local $o) (i64.load offset=24 (get_local $t)))
	(i64.store16 offset=8 (get_local $o) (i64.load offset=32 (get_local $t)))
	(i64.store16 offset=10 (get_local $o) (i64.load offset=40 (get_local $t)))
	(i64.store16 offset=12 (get_local $o) (i64.load offset=48 (get_local $t)))
	(i64.store16 offset=14 (get_local $o) (i64.load offset=56 (get_local $t)))
	(i64.store16 offset=16 (get_local $o) (i64.load offset=64 (get_local $t)))
	(i64.store16 offset=18 (get_local $o) (i64.load offset=72 (get_local $t)))
	(i64.store16 offset=20 (get_local $o) (i64.load offset=80 (get_local $t)))
	(i64.store16 offset=22 (get_local $o) (i64.load offset=88 (get_local $t)))
	(i64.store16 offset=24 (get_local $o) (i64.load offset=96 (get_local $t)))
	(i64.store16 offset=26 (get_local $o) (i64.load offset=104 (get_local $t)))
	(i64.store16 offset=28 (get_local $o) (i64.load offset=112 (get_local $t)))
	(i64.store16 offset=30 (get_local $o) (i64.load offset=120 (get_local $t)))
);; Author: Torsten Stüber

;; input/output pointer $p: 16 i64 = 128 bytes
;; input/output pointer $q: 16 i64 = 128 bytes
;; input value $b (is 1 or 0)
(func $sel25519 (export "sel25519") untrusted
	(param $p i32)
	(param $q i32)
	(param $b i32)

	(local $t i64)
	(local $c i64)

	(set_local $c (i64.xor (i64.sub (i64.extend_u/i32 (get_local $b)) (i64.const 1)) (i64.const -1)))
	
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=0 (get_local $p)) (i64.load offset=0 (get_local $q)))))
	(i64.store offset=0 (get_local $p) (i64.xor (i64.load offset=0 (get_local $p)) (get_local $t)))
	(i64.store offset=0 (get_local $q) (i64.xor (i64.load offset=0 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=8 (get_local $p)) (i64.load offset=8 (get_local $q)))))
	(i64.store offset=8 (get_local $p) (i64.xor (i64.load offset=8 (get_local $p)) (get_local $t)))
	(i64.store offset=8 (get_local $q) (i64.xor (i64.load offset=8 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=16 (get_local $p)) (i64.load offset=16 (get_local $q)))))
	(i64.store offset=16 (get_local $p) (i64.xor (i64.load offset=16 (get_local $p)) (get_local $t)))
	(i64.store offset=16 (get_local $q) (i64.xor (i64.load offset=16 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=24 (get_local $p)) (i64.load offset=24 (get_local $q)))))
	(i64.store offset=24 (get_local $p) (i64.xor (i64.load offset=24 (get_local $p)) (get_local $t)))
	(i64.store offset=24 (get_local $q) (i64.xor (i64.load offset=24 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=32 (get_local $p)) (i64.load offset=32 (get_local $q)))))
	(i64.store offset=32 (get_local $p) (i64.xor (i64.load offset=32 (get_local $p)) (get_local $t)))
	(i64.store offset=32 (get_local $q) (i64.xor (i64.load offset=32 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=40 (get_local $p)) (i64.load offset=40 (get_local $q)))))
	(i64.store offset=40 (get_local $p) (i64.xor (i64.load offset=40 (get_local $p)) (get_local $t)))
	(i64.store offset=40 (get_local $q) (i64.xor (i64.load offset=40 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=48 (get_local $p)) (i64.load offset=48 (get_local $q)))))
	(i64.store offset=48 (get_local $p) (i64.xor (i64.load offset=48 (get_local $p)) (get_local $t)))
	(i64.store offset=48 (get_local $q) (i64.xor (i64.load offset=48 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=56 (get_local $p)) (i64.load offset=56 (get_local $q)))))
	(i64.store offset=56 (get_local $p) (i64.xor (i64.load offset=56 (get_local $p)) (get_local $t)))
	(i64.store offset=56 (get_local $q) (i64.xor (i64.load offset=56 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=64 (get_local $p)) (i64.load offset=64 (get_local $q)))))
	(i64.store offset=64 (get_local $p) (i64.xor (i64.load offset=64 (get_local $p)) (get_local $t)))
	(i64.store offset=64 (get_local $q) (i64.xor (i64.load offset=64 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=72 (get_local $p)) (i64.load offset=72 (get_local $q)))))
	(i64.store offset=72 (get_local $p) (i64.xor (i64.load offset=72 (get_local $p)) (get_local $t)))
	(i64.store offset=72 (get_local $q) (i64.xor (i64.load offset=72 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=80 (get_local $p)) (i64.load offset=80 (get_local $q)))))
	(i64.store offset=80 (get_local $p) (i64.xor (i64.load offset=80 (get_local $p)) (get_local $t)))
	(i64.store offset=80 (get_local $q) (i64.xor (i64.load offset=80 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=88 (get_local $p)) (i64.load offset=88 (get_local $q)))))
	(i64.store offset=88 (get_local $p) (i64.xor (i64.load offset=88 (get_local $p)) (get_local $t)))
	(i64.store offset=88 (get_local $q) (i64.xor (i64.load offset=88 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=96 (get_local $p)) (i64.load offset=96 (get_local $q)))))
	(i64.store offset=96 (get_local $p) (i64.xor (i64.load offset=96 (get_local $p)) (get_local $t)))
	(i64.store offset=96 (get_local $q) (i64.xor (i64.load offset=96 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=104 (get_local $p)) (i64.load offset=104 (get_local $q)))))
	(i64.store offset=104 (get_local $p) (i64.xor (i64.load offset=104 (get_local $p)) (get_local $t)))
	(i64.store offset=104 (get_local $q) (i64.xor (i64.load offset=104 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=112 (get_local $p)) (i64.load offset=112 (get_local $q)))))
	(i64.store offset=112 (get_local $p) (i64.xor (i64.load offset=112 (get_local $p)) (get_local $t)))
	(i64.store offset=112 (get_local $q) (i64.xor (i64.load offset=112 (get_local $q)) (get_local $t)))
	(set_local $t (i64.and (get_local $c) (i64.xor (i64.load offset=120 (get_local $p)) (i64.load offset=120 (get_local $q)))))
	(i64.store offset=120 (get_local $p) (i64.xor (i64.load offset=120 (get_local $p)) (get_local $t)))
	(i64.store offset=120 (get_local $q) (i64.xor (i64.load offset=120 (get_local $q)) (get_local $t)))
)
;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
(func $S (export "S") untrusted
	(param $o i32)
	(param $a i32)

	(get_local $o)
	(get_local $a)
	(get_local $a)
	(call $M)
);; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $n: 32 bytes
(func $unpack25519 (export "unpack25519") untrusted
	(param $o i32)
	(param $n i32)

	(i64.store offset=0   (get_local $o) (i64.load16_u offset=0  (get_local $n)))
	(i64.store offset=8   (get_local $o) (i64.load16_u offset=2  (get_local $n)))
	(i64.store offset=16  (get_local $o) (i64.load16_u offset=4  (get_local $n)))
	(i64.store offset=24  (get_local $o) (i64.load16_u offset=6  (get_local $n)))
	(i64.store offset=32  (get_local $o) (i64.load16_u offset=8  (get_local $n)))
	(i64.store offset=40  (get_local $o) (i64.load16_u offset=10 (get_local $n)))
	(i64.store offset=48  (get_local $o) (i64.load16_u offset=12 (get_local $n)))
	(i64.store offset=56  (get_local $o) (i64.load16_u offset=14 (get_local $n)))
	(i64.store offset=64  (get_local $o) (i64.load16_u offset=16 (get_local $n)))
	(i64.store offset=72  (get_local $o) (i64.load16_u offset=18 (get_local $n)))
	(i64.store offset=80  (get_local $o) (i64.load16_u offset=20 (get_local $n)))
	(i64.store offset=88  (get_local $o) (i64.load16_u offset=22 (get_local $n)))
	(i64.store offset=96  (get_local $o) (i64.load16_u offset=24 (get_local $n)))
	(i64.store offset=104 (get_local $o) (i64.load16_u offset=26 (get_local $n)))
	(i64.store offset=112 (get_local $o) (i64.load16_u offset=28 (get_local $n)))
	(i64.store offset=120 (get_local $o) (i64.and (i64.load16_u offset=30 (get_local $n)) (i64.const 0x7fff)))
);; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
(func $Z (export "Z") untrusted
	(param $o i32)
	(param $a i32)
	(param $b i32)

	(i64.store offset=0 (get_local $o) (i64.sub (i64.load offset=0 (get_local $a)) (i64.load offset=0 (get_local $b))))
	(i64.store offset=8 (get_local $o) (i64.sub (i64.load offset=8 (get_local $a)) (i64.load offset=8 (get_local $b))))
	(i64.store offset=16 (get_local $o) (i64.sub (i64.load offset=16 (get_local $a)) (i64.load offset=16 (get_local $b))))
	(i64.store offset=24 (get_local $o) (i64.sub (i64.load offset=24 (get_local $a)) (i64.load offset=24 (get_local $b))))
	(i64.store offset=32 (get_local $o) (i64.sub (i64.load offset=32 (get_local $a)) (i64.load offset=32 (get_local $b))))
	(i64.store offset=40 (get_local $o) (i64.sub (i64.load offset=40 (get_local $a)) (i64.load offset=40 (get_local $b))))
	(i64.store offset=48 (get_local $o) (i64.sub (i64.load offset=48 (get_local $a)) (i64.load offset=48 (get_local $b))))
	(i64.store offset=56 (get_local $o) (i64.sub (i64.load offset=56 (get_local $a)) (i64.load offset=56 (get_local $b))))
	(i64.store offset=64 (get_local $o) (i64.sub (i64.load offset=64 (get_local $a)) (i64.load offset=64 (get_local $b))))
	(i64.store offset=72 (get_local $o) (i64.sub (i64.load offset=72 (get_local $a)) (i64.load offset=72 (get_local $b))))
	(i64.store offset=80 (get_local $o) (i64.sub (i64.load offset=80 (get_local $a)) (i64.load offset=80 (get_local $b))))
	(i64.store offset=88 (get_local $o) (i64.sub (i64.load offset=88 (get_local $a)) (i64.load offset=88 (get_local $b))))
	(i64.store offset=96 (get_local $o) (i64.sub (i64.load offset=96 (get_local $a)) (i64.load offset=96 (get_local $b))))
	(i64.store offset=104 (get_local $o) (i64.sub (i64.load offset=104 (get_local $a)) (i64.load offset=104 (get_local $b))))
	(i64.store offset=112 (get_local $o) (i64.sub (i64.load offset=112 (get_local $a)) (i64.load offset=112 (get_local $b))))
	(i64.store offset=120 (get_local $o) (i64.sub (i64.load offset=120 (get_local $a)) (i64.load offset=120 (get_local $b))))
	
))
