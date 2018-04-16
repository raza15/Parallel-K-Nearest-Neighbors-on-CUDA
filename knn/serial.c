#include <stdio.h>
#include <stdlib.h>

const int ROWS = 3;
const int COLS = 3;

void printMatrix(int matrix[ROWS][COLS]) {
	int row; int col;
	for(row = 0; row < ROWS; row++) {
		for(col = 0; col < COLS; col++) {
			printf("%d, ", matrix[row][col]);
		}
		printf("\n");
	}
}

void populateMatrix(const char * fileName, int matrix[ROWS][COLS]) {
	FILE * fp;  
        fp = fopen(fileName, "r+");
        int row; int col;
        for(row = 0; row < ROWS; row++) {
                for(col = 0; col < COLS; col++) {
                        fscanf(fp, "%d", &matrix[row][col]);
                }
        }
}

int main() {
	int matrix[ROWS][COLS];
	populateMatrix("testData.txt", matrix);
	printf("Hello World!\n");
	printMatrix(matrix);
	return 0;
}
