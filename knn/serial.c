#include <stdio.h>
#include <stdlib.h>

const int USERS = 3;
const int ATTRIBUTES = 5;
const int K = 1;

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

void printScores(int matrix[USERS][USERS]) {
        int row; int col;
	printf("Scores:-\n");
        for(row = 0; row < USERS; row++) {
                for(col = 0; col < USERS; col++) {
                        printf("%d, ", matrix[row][col]);
                }
                printf("\n");
        }
}

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

void calculateScores(int matrix[USERS][ATTRIBUTES], int scores[USERS][USERS]) {

}

int main() {
	int matrix[USERS][ATTRIBUTES];
	readDataFromFile("testData.txt", matrix);
	printMatrix(matrix);
	int scores[USERS][USERS];
	calculateScores(matrix, scores);
	printScores(scores);
	return 0;
}
