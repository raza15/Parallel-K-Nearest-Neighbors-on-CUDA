#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define MAX_VALUE 2147483647

void printMatrix(int *matrix, int users, int attributes) {
	printf("Matrix:-\n");
	for(int i = 0; i < (users * attributes); i++) {
        if(i % attributes == 0 && i != 0) {
            printf("\n%d ", matrix[i]);
        } else {
            printf("%d ", matrix[i]);
        }
	}
	printf("\n");
}

void printScores(int *matrix, int users) {
	printf("Scores:-\n");
	for(int i = 0; i < (users * users); i++) {
        if(i % users == 0 && i != 0) {
            printf("\n%d ", matrix[i]);
        } else {
            printf("%d ", matrix[i]);
        }
	}
	printf("\n");
}

void printTopKClosest(int *topKClosest, int users, int K) {
	printf("Top K Closest Data Points For Each Data Point:-\n");
	for(int i = 0; i < (users * K); i++) {
		printf("%d: ", i);
        if(i % users == 0 && i != 0) {
            printf("\n%d ", topKClosest[i]);
        } else {
            printf("%d ", topKClosest[i]);
        }
	}
	printf("\n");
}

// todo: handle for the case where distance exceeds the MAX_VALUE of INTEGER
void euclideanDistance(int *row1, int *row2, int attributes, int * distance) {
	*distance = 0;
	for(int col = 0; col < attributes; col++) {
		int difference = row1[col] - row2[col];
		*distance = *distance + difference * difference;
	}
}

void copyAllAttributes(int *copyFrom, int *copyTo, int attributes) {
	for(int index = 0; index < attributes; index++) {
		copyTo[index] = copyFrom[index];
	}
}

void calculateScores(int *matrix, int *scores, int users, int attributes) {
	for(int row = 0; row < users; row++) {
        int distance = 0;
		for(int col = 0; col < row; col++) {
            for(int k = 0; k < attributes; k++) {
                int row1 = users*col + k;
                int row2 = attributes*row + k;
                printf("Row: %d Col: %d K: %d data: %d other data %d Index %d\n", row,col,k, matrix[row1], matrix[row2], row2);
                int difference = matrix[row*users + k] - matrix[attributes*col + k];
                distance = distance + (difference * difference);
            }
            printf("Distance: %d\n", distance);
			//int distance;
			//euclideanDistance(&row1, &row2, attributes, &distance);
			//scores[row + col] = distance;
			//printf(" %d \n", matrix[row + col]);
		}
        printf("\n");
	}
}

// time complexity for KNN for 1 user: O(n.k) where n = # of users and k = # of closest neighbors to calculate
// By using the max heap of size k, we can can reduce the time complexity to: O(nlogk)
// But that won't make much of a difference because k <<< n
void calculateTopKClosest(int *scores, int *topKClosest, int users, int K) {
	int minValue, minIndex, value, user, k, index;
	for(user = 0; user < users; user++) {
		for(k = 0; k < K; k++) {
			minValue = MAX_VALUE;
			minIndex = -1;
			for(index = 0; index < users; index++) {
				value = scores[user + index];
				if(value < minValue && index != user) {
					minValue = value;
					minIndex = index;
				}
			}
			if(minIndex != -1) {
				scores[user + minIndex] = MAX_VALUE;
			}
			topKClosest[user + k] = minIndex;
		}
	}
}

int main(int argc, char **argv) {
	// Check input
    if(argc < 4) {
        printf("Usage: %s <k> <users> <attributes>\n", argv[0]);
        return 0;
    }

	int *dataSet;
	int k = atoi(argv[1]);
	int users = atoi(argv[2]);
	int attributes = atoi(argv[3]);

	dataSet = (int *)malloc(sizeof(int) * users * attributes);
    if(dataSet != NULL) {
        printf("Allocated an array for %d users and %d attributes\n", users, attributes);
    } else {
        printf("Couldn't allocate dataSet array, quitting!\n");
        exit(0);
    }

    // Seed the RNG
    srand(time(NULL));
    // Now fill dataSet with some values
    for(int i=0; i < (users * attributes); i++)
        //dataSet[i] = rand() % 1000; // Random integers between 0 and 1,000
        dataSet[i] = rand() % 15; // Random integers between 0 and 1,000

    int *scores;
    scores = (int *)malloc(sizeof(int) * users * users);
    if(scores != NULL) {
        printf("Allocated a square scores array for %d users\n", users);
    } else {
        printf("Couldn't allocate scores array, quitting!\n");
        exit(0);
    }

    printMatrix(dataSet, users, attributes);
    calculateScores(dataSet, &scores, users, attributes);
	//printScores(&scores, users);
	/*
	if(K <= 0 || K >= users) {
		printf("Ivalid K: K should be > 0 && < # of users");
		return 0;
	}
	int topKClosest[users][K];
	calculateTopKClosest(scores, topKClosest);
	printTopKClosest(topKClosest);
    */

    // Clean up after ourselves
    free(dataSet); free(scores);
	return 0;
}
