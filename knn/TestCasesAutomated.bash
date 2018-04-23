#!/bin/bash

rm "results_serial.csv"
rm "results_parallel.csv"
rm "results.csv"

k=100

for program in "serial" "parallel"
do
	for attributes in 1 4 16 64 256
	do
		for users in 256 512 1024 2048 4096 8192 16384
		do
			fileName="results_$program.csv"
			echo users = $users $fileName
			./knnCuda $k $users $attributes $program $fileName
		done
	done
done
