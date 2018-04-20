clean:
	rm -rf a.out cuda knnCuda serial serial_100 serial_1000 serial_5000 serial_10000 serial_50000
serial:
	gcc -o serial serial.c
cuda:
	nvcc -o knnCuda knnCuda.cu
testserial100:
	gcc -o serial_100 serial_100.c
	time ./serial_100 
testserial1000:
	gcc -o serial_1000 serial_1000.c
	time ./serial_1000
testserial5000:
	gcc -o serial_5000 serial_5000.c
	time ./serial_5000
testserial10000:
	gcc -o serial_10000 serial_10000.c
	time ./serial_10000
testserial50000:
	gcc -o serial_50000 serial_50000.c
	time ./serial_50000
