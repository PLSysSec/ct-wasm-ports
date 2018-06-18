default: run

run:
	cd ../ct && make
	cd ../reference && make
	ct-node bench.js
	./median.py *.measurements

clean:
	rm -f *.measurements
