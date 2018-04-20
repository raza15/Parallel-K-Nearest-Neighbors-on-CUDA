#!/bin/bash

rm "results_serial.csv"
rm "results_parallel.csv"
echo "whichProgramToRun, users, attributes, k, timeTaken (seconds)\n" > "results_serial.csv"
echo "whichProgramToRun, users, attributes, k, timeTaken (seconds)\n" > "results_parallel.csv"
nvcc knnCuda.cu -o knnCuda

k=1
attributes=5

usersStartRange=10
usersEndRange=89000

for ((users = $usersStartRange; users <= $usersEndRange; users = users*2));
do
	echo users = $users
	./knnCuda $k $users $attributes serial
done

for ((users = $usersStartRange; users <= $usersEndRange; users = users*2));
do
        echo users = $users
        ./knnCuda $k $users $attributes parallel
done
