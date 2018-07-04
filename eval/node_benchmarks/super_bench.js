for i in `seq 1 100`; do
	echo "ROUND $i"
	./bench.sh
	mkdir $i
	mv *.bench $i
done
