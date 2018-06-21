default: run

run:
	cd ../ && make
	ct-node bench.js
	./median.py *.measurements

clean:
	rm -f *.measurements
