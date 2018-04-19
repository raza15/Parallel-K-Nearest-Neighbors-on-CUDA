#include <stdio.h>
#include <stdlib.h>

#define MAX_VALUE 2147483647

const int USERS = 3;
const int ATTRIBUTES = 5;
// const int K = 2;

void readDataFromFile(const char * fileName, int matrix[USERS][ATTRIBUTES]) {
	FILE * fp;  
        fp = fopen(fileName, "r+");
        int row; int col;
        for(row = 0; row < USERS; row++) {
                for(col = 0; col < ATTRIBUTES; col++) {
                        fscanf(fp, "%d", &matrix[row][col]);
                }
        }
}

void printMatrix(int matrix[USERS][ATTRIBUTES]) {
	int row; int col;
	printf("Matrix:-\n");
	for(row = 0; row < USERS; row++) {
		for(col = 0; col < ATTRIBUTES; col++) {
			printf("%d, ", matrix[row][col]);
		}
		printf("\n");
	}
}

void printArray(int * array, int size) {
	int i;
	for(i = 0; i < size; i++) {
		printf("%d, ", array[i]);
	}
	printf("\n");
}

int* matrixTo1DArray(int matrix[USERS][ATTRIBUTES]) {
	int* newArray = new int[USERS*ATTRIBUTES];
	int h; int w;
	for(h = 0; h < USERS; h++) {
		for(w = 0; w < ATTRIBUTES; w++) {
			newArray[ATTRIBUTES * h + w] = matrix[h][w];
		}
	}
	return newArray;
}
/*
__global__ void calculateScoresKernel(int * matrixArray, int * scores) {
	int row; int col;
	int row1[ATTRIBUTES];
	int row2[ATTRIBUTES];
	for(row = 0; row < USERS; row++) {
		copyAllAttributes(matrix[row], row1);
		for(col = 0; col < USERS; col++) {
			copyAllAttributes(matrix[col], row2);
			int distance;
			eucladeanDistance(row1, row2, &distance);
			scores[row][col] = distance;
		}
	}
}
*/
int* calculateScores(int * array) {
	int * output = new int[USERS*USERS];
	return output;
}

int main(void) {
	int matrix[USERS][ATTRIBUTES];
	readDataFromFile("testData.txt", matrix);
	printMatrix(matrix);
	int * matrixArray = matrixTo1DArray(matrix);
	// printArray(matrixArray, USERS*ATTRIBUTES);
	int * scores = calculateScores(matrixArray);
}
