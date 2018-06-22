default: run

run: 
	cd ../reference && make
	ct-node bench.js
	./median.py *.measurements

clean:
	rm -f *.measurements
