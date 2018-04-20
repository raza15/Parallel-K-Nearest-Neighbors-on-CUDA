#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define MAX_VALUE 2147483647

const int USERS = 10000;
const int ATTRIBUTES = 5;
const int K = 2;
int scores[USERS][USERS];

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

void printTopKClosest(int topKClosest[USERS][K]) {
    int row; int col;
        printf("Top K Closest Data Points For Each Data Point:-\n");
        for(row = 0; row < USERS; row++) {
        printf("%d: ", row);
                for(col = 0; col < K; col++) {
                        printf("%d, ", topKClosest[row][col]);
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

// todo: handle for the case where distance exceeds the MAX_VALUE of INTEGER
void eucladeanDistance(int row1[ATTRIBUTES], int row2[ATTRIBUTES], int * distance) {
    int col;
    *distance = 0;
    for(col = 0; col < ATTRIBUTES; col++) {
        int difference = row1[col] - row2[col];
        *distance = *distance + difference * difference;
    }
}

void copyAllAttributes(int copyFrom[ATTRIBUTES], int copyTo[ATTRIBUTES]) {
    int index;
    for(index = 0; index < ATTRIBUTES; index++) {
        copyTo[index] = copyFrom[index];
    }
}

void calculateScores(int matrix[USERS][ATTRIBUTES], int scores[USERS][USERS]) {
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

// time complexity for KNN for 1 user: O(n.k) where n = # of users and k = # of closest neighbors to calculate
// By using the max heap of size k, we can can reduce the time complexity to: O(nlogk)
// But that won't make much of a difference because k <<< n
void calculateTopKClosest(int scores[USERS][USERS], int topKClosest[USERS][K]) {
    int minValue, minIndex, value, user, k, index;
    for(user = 0; user < USERS; user++) {
        for(k = 0; k < K; k++) {
            minValue = MAX_VALUE;
            minIndex = -1;
            for(index = 0; index < USERS; index++) {
                value = scores[user][index];
                if(value < minValue && index != user) {
                    minValue = value;
                    minIndex = index;
                }
            }
            if(minIndex != -1) {
                scores[user][minIndex] = MAX_VALUE;
            }
            topKClosest[user][k] = minIndex;
        }
    }
}

int main() {
    time_t start = time(NULL);
    int matrix[USERS][ATTRIBUTES];
    readDataFromFile("testData_10000.txt", matrix);
    //printMatrix(matrix);
    calculateScores(matrix, scores);
    //printScores(scores);
    if(K <= 0 || K >= USERS) {
        printf("Ivalid K: K should be > 0 && < # of users");
        return 0;
    }
    int topKClosest[USERS][K];
    calculateTopKClosest(scores, topKClosest);
    //printTopKClosest(topKClosest);
    printf("\nTime taken: %ld seconds\n", time(NULL) - start);
    return 0;
}

