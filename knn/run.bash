#!/bin/bash

nvcc knnCuda.cu -o knnCuda
./knnCuda 1 3 2
